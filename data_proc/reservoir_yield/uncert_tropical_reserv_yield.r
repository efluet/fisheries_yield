df <- read.csv('../data/reservoir_yield/ResYield_data_modeling_Feb2018_tropical_reserv_reg.csv') %>% 
  filter(date.of.data != '') #is.na(X))
df

m <- lm(logC ~ logA, df)
m

ggplot(df, aes(x=logA, y=logC)) +
  geom_smooth(method = "lm", fullrange = TRUE, color='grey60') +
  geom_point() + 
  xlab('log Reservoir Area') +
  xlab('log Reservoir Catch') +
  ggtitle('Tropical reservoir yield') +
  line_plot_theme()


# predict(m, interval = "confidence")
uncert_range <- predict(m, interval = "prediction") %>% 
  data.frame()
# names(uncert_range) <- c('pred','lwr','upr')



uncert_range <- 
  uncert_range %>% 
  mutate(fit = 10^fit,
         lwr = 10^lwr,
         upr = 10^upr) 

  # mutate(fit = 10^(log10(fit)),
  #        lwr = 10^(log10(lwr)),
  #        upr = 10^(log10(upr))) %>% 
  replace(is.na(.), 0)

uncert_range

colSums(uncert_range)

sum(10^(df$logC))

# lm_eqn <- function(df){
#   m <- lm(y ~ x, df);
#   eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
#                    list(a = format(unname(coef(m)[1]), digits = 2),
#                         b = format(unname(coef(m)[2]), digits = 2),
#                         r2 = format(summary(m)$r.squared, digits = 3)))
#   as.character(as.expression(eq));
# }
# 
# p1 <- p + geom_text(x = 25, y = 300, label = lm_eqn(df), parse = TRUE)