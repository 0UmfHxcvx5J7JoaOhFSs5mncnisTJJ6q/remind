library(tidyverse)

d <- tribble(
    ~emiInd37,        ~period,    ~cost,   ~abatement,
    'co2cement',      2030,        95,     0.63,
    'co2cement',      2030,       133,     0.76,
    'co2cement',      2040,        54,     0.70,
    'co2cement',      2040,       133,     0.76,
    'co2chemicals',   2030,        78,     0.12,
    'co2chemicals',   2030,        80,     0.57,
    'co2chemicals',   2040,        46,     0.36,
    'co2chemicals',   2040,        78,     0.48,
    'co2chemicals',   2040,        80,     0.57,

    # old "early" steel MAC
    'co2steel',       2030,        59,     0.12,
    'co2steel',       2030,        82,     0.23,

    # new steel MAC
    'co2steel',       2040,        49,     0.43,
    'co2steel',       2040,        51,     0.61,
    'co2steel',       2040,        54,     0.67,
    'co2steel',       2040,        56,     0.73,
    'co2steel',       2040,        66,     0.74)

d <- d %>%
    arrange(period, cost) %>%
    reframe(cost = c(0, cost, Inf),
            abatement = c(0, abatement, last(abatement)),
            .by = c('emiInd37', 'period'))

d <- d %>%
    distinct(emiInd37, cost) %>%
    arrange(emiInd37, cost) %>%
    expand_grid(period = seq(from = min(d$period), to = max(d$period),
                             by = 5)) %>%
    left_join(
        d %>%
            filter(period %in% range(.data$period)),

        c('emiInd37', 'period', 'cost')
    ) %>%
    group_by(emiInd37, period) %>%
    arrange(emiInd37, period, cost) %>%
    fill(abatement) %>%
    group_by(emiInd37, cost) %>%
    arrange(emiInd37, cost, period) %>%
    mutate(abatement = zoo::na.approx(
        object = !!sym('abatement'),
        x = !!sym('period'),
        na.rm = FALSE)) %>%
    ungroup()

ggplot() +
    geom_step(data = d,
              mapping = aes(x = cost, y = abatement * 100,
                            colour = as.factor(period)),
              direction = 'hv') +
    scale_colour_discrete(name = NULL) +
    facet_wrap(~ emiInd37, ncol = 2) +
    coord_cartesian(
        xlim = c(0, ceiling(max(Filter(is.finite, d$cost)) / 10) * 10),
        ylim = c(0, 100), expand = FALSE) +
    labs(x = '$/t CO2', y = 'Abatement [%]') +
    theme_minimal() +
    theme(legend.position = c(1, 0),
          legend.justification = c(1, 0))

d %>%
    filter(!(0 == cost | is.infinite(cost) | 0 == abatement)) %>%
    arrange(period, emiInd37) %>%
    mutate(text = sprintf('pm_abatparam_Ind(ttot,regi,"%s",step)$( sm_tmp ge %3i ) = %-.2g;',
                          emiInd37, cost, abatement)) %>%
    pull(text) %>%
    cat(sep = '\n')
