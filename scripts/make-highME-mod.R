library(tidyverse)
library(assertr)

base_path <- '/p/projects/rd3mod/inputdata/output/rev6.75-indccslim2'
idr_tar <- list.files(dirname(base_path),
                      paste0(basename(base_path), '_62eff8f7_remind.tgz$'),
                      full.names = TRUE)

dir.create(tar_dir <- file.path(tempdir(),
                                sub('\\.tgz$', '', basename(idr_tar))),
           showWarnings = FALSE)

untar(tarfile = idr_tar, exdir = tar_dir)

fe_file  <- file.path(tar_dir, 'f_fedemand.cs4r')
kap_file <- file.path(tar_dir, 'f29_capitalQuantity.cs4r')

fe_lines <- read_lines(file = fe_file)

fe_data <- read_csv(file = fe_file,
                    col_names = c('t', 'regi', 'scenario', 'pf', 'value'),
                    col_types = 'icccd',
                    comment = '*')

kap_lines <- read_lines(file = kap_file)
kap_data <- read_csv(file = kap_file,
                     col_names = c('t', 'regi', 'scenario', 'pf', 'value'),
                     col_types = 'icccd',
                     comment = '*')


lambda <- expand_grid(
    t = unique(fe_data$t),
    subsector = c('cement', 'chemicals', 'steel', 'otherInd')) %>%
    inner_join(
        tribble(
            ~subsector,    ~lambda,
            'cement',      -0.15,
            'chemicals',   -0.10,
            'steel',       -0.23,
            'otherInd',    -0.10),

        'subsector'
    ) %>%
    mutate(lambda = case_when(
        2020 >= t ~ 1,
        2020 < t & t < 2050 ~
            1 + (t - 2020) / (2050 - 2020) * lambda,
        2050 <= t ~ 1 + lambda))

write_lines(
    x = c(grep('^\\*', fe_lines, value = TRUE),
          paste('* modified', Sys.Date(), 'for lower SSP2EU specific industry',
                'service, FE, and capital demand')),
    file = fe_file, append = FALSE)

write_csv(
    x = bind_rows(
        fe_data %>%
            filter(
                'gdp_SSP2EU' == scenario,
                grepl('^(ue|fe.*)_(cement|chemicals|steel|otherInd)', pf)) %>%
            extract('pf', c(NA, 'subsector'), '^(ue|fe[^_]+)_([^_]+).*',
                    remove = FALSE) %>%
            full_join(lambda, c('t', 'subsector')) %>%
            assert(not_na, everything()) %>%
            mutate(value = value * lambda) %>%
            select(-lambda, -subsector),

        fe_data %>%
            filter(  'gdp_SSP2EU' != scenario
                   | !grepl('^(ue|fe.*)_(cement|chemicals|steel|otherInd)', pf))
    ) %>%
    group_by(t, regi, scenario, pf) %>%
    mutate(count = n()) %>%
    verify(1 == count) %>%
    select(-count),
    file = fe_file, append = TRUE, col_names = FALSE)

write_lines(
    x = c(grep('^\\*', kap_lines, value = TRUE),
          paste('* modified', Sys.Date(), 'for lower SSP2EU specific industry',
                'service, FE, and capital demand')),
    file = kap_file, append = FALSE)

write_csv(
    x = bind_rows(
        kap_data %>%
            filter('gdp_SSP2EU' == scenario,
                   grepl('^kap_(cement|chemicals|steel|otherInd)', pf)) %>%
            extract('pf', 'subsector', '^kap_([^_]+).*', remove = FALSE) %>%
            full_join(
                lambda %>%
                    semi_join(kap_data, 't'),

                c('t', 'subsector')
            ) %>%
            assert(not_na, everything()) %>%
            mutate(value = value * lambda) %>%
            select(-lambda, -subsector),

        kap_data %>%
            filter(  'gdp_SSP2EU' != scenario
                   | !grepl('^kap_(cement|chemicals|steel|otherInd)', pf))
    ) %>%
    group_by(t, regi, scenario, pf) %>%
    mutate(count = n()) %>%
    verify(1 == count) %>%
    select(-count),
    file = kap_file, append = TRUE, col_names = FALSE)

system(paste('tar --create --gzip --file',
             sub('^(.*rev[0-9\\.]+)_(.*)$',
                 'calibration_results/\\1-highME-mod_\\2',
                 basename(idr_tar)),
             '-C', tar_dir,
             paste(list.files(tar_dir), collapse = ' ')))

file.copy(sub('_remind.tgz$', '_validationremind.tgz', idr_tar),
          sub('^.*(rev[0-9\\.]+)_([0-9a-f]{8})_remind.tgz',
              'calibration_results/\\1-highME-mod_\\2_validationremind.tgz',
              idr_tar),
          overwrite = TRUE)
