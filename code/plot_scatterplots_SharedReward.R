# set working directory
library("here")

# load packages
library("readxl")
library("ggplot2")
library("ggpubr")
library("reshape2")
library("emmeans")
library("hrbrthemes")
library("umx")
library("interactions")
library("car")
library("dplyr")

library (tidyverse)
library(rstatix)
library(reshape)
library(datarium)

setwd("C:/Users/tup54227/Documents/GitHub/istart-sharedreward/derivatives/")
maindir <- getwd()
datadir <- file.path("../derivatives/")

# import data
#here()
sharedreward <- read_excel("ppi_wholebrain_scatterplot.xls")
behavioral <- read_excel("ISTART-ALL-Combined-042122.xlsx")
postscan_ratings <- read.csv("df_psr.csv")
df_TPJ <- read_excel("df_TPJ.xlsx")
df_VS_ROI <- read_excel("VS_ROI_activation.xlsx")
df_VS_TPJ_ROI <- read_excel("VS-TPJ_ROI_connectivity.xlsx")
total <- inner_join(sharedreward, df_TPJ, by = "sub")
#srpr <- read.csv("../../istart/Shared_Reward/Behavioral_Analysis/SharedRewardPeerRatingsLongform.csv")


#Behavioral ratings and personality factors plot
Win_F_C <- lm(`Win_F_C` ~ RS + RS_square + SU + SUxRS + SUxRS_sq, data=postscan_ratings)
Behavior_RS_r <- cor(postscan_ratings$RS, postscan_ratings$`Win_F_C`, method = 'pearson')
print(Behavior_RS_r)
summary(Win_F_C)
scatter <- ggplot(data = postscan_ratings, aes(x=RS,
                                    y=`Win_F_C`))+
  geom_smooth(method=lm, formula = y ~ poly(x,2), level = 0.99, 
              se=TRUE, fullrange=TRUE, color="black")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))
ggsave(
  "../derivatives/Figures/RS_behavioral.svg",
  plot = scatter, bg = "white")



# Shared Reward Model 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VS_substance_F_C <- lm(`VS_seed_F_C` ~ tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(VS_substance_F_C)
crModel <- crPlots(VS_substance_F_C,
                   smooth=FALSE,
                   pch=21, #shape of dot
                   col='black', #dot outline color
                   bg='blue', #unclear
                   col.lines='yellow', #trend line color
                   lwd=1,
                   grid=FALSE)

# IMPORTANT -- VS-FFA Connectivity: Reward with Friend v Computer, zstat 1 cluster 1 (main effect) Ventral Striatum ppi seed
model6 <- lm(`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-16` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model6)

scatter <- ggplot(data = total, aes(x=RS,
                                    y=`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-16`))+
  geom_smooth(method=lm, level = 0.99, 
              se=TRUE, fullrange=TRUE, color="black")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))
#above plots RS result, below plots SU result
#scatter <- ggplot(data = total, aes(x=SU,
#                                    y=`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-16`))+
#  geom_smooth(method=lm, level = 0.99, 
#              se=FALSE, fullrange=TRUE, linetype="dashed",)+
#  geom_point(shape=1,color="black")
#scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
#                                     panel.grid.minor = element_blank(), 
#                                     panel.background = element_blank(), 
#                                     axis.line =  element_line(colour="black"))

summary(model6)
      
      #checking if result exists in stranger v computer as well (it doesn't)
model6b <- lm(`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-15_rew_S-C` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model6b
summary(model6b)

# VS-left occipital/FFA: Reward with Friend v Computer, zstat 1 cluster 2 (main effect) Ventral Striatum ppi seed
model7 <- lm(`ppi_C16_rew_F-C_z1_main-effect_cluster2_type-ppi_seed-VS_thr5_cope-16` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model7)
crPlots(model7, smooth=FALSE)

# IMPORANT -- Reward with Friend v Stranger + Computer, zstat 12 cluster (SUxRS_square-neg) Ventral Striatum ppi seed
model9 <- lm(`ppi_C23_rew-pun_F-SC_z12_su-rs2-neg_cluster3_type-ppi_seed-VS_thr5_cope-23` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model9
total$SU_qualifier <- cut(sharedreward$SU,
                          breaks = c(-2, 0, 6),
                          labels = c("low","high"))
total$SU_qualifier

# IMPORANT -- Reward with Friend v Stranger + Computer, zstat 12 cluster (SUxRS_square-neg) Ventral Striatum ppi seed
model9 <- lm(`ppi_C23_rew-pun_F-SC_z12_su-rs2-neg_cluster3_type-ppi_seed-VS_thr5_cope-23` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model9)
total$SU_qualifier <- cut(sharedreward$SU,
                          breaks = c(-2, 0, 6),
                          labels = c("low","high"))
total$SU_qualifier
            #VS-STS Rew-Pun for Friend v Str + Comp, moderated by SUxRS^2 interaction
scatter <- ggplot(data = total, aes(x=RS,
                                    y=`ppi_C23_rew-pun_F-SC_z12_su-rs2-neg_cluster3_type-ppi_seed-VS_thr5_cope-23`, 
                                    col = SU_qualifier))+
  geom_smooth(method=lm, formula = y ~ poly(x,2), level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed")+
  geom_point(shape=1,color="black")+
  scale_x_continuous(breaks = seq(-6, 6, by = 2))
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))

# STG activation: Reward with Friend v Computer, zstat 2 cluster 1 (substance use) activation model exploratory result
model10 <- lm(`act_C16_rew_F-C_z2_sub_cluster1_type-act_cope-16` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model10)
scatter <- ggplot(data = sharedreward, aes(x=SU,
                                    y=`act_C16_rew_F-C_z2_sub_cluster1_type-act_cope-16`))+
  geom_smooth(method=lm, level = 0.99, 
              se=TRUE, fullrange=TRUE, color="black")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))

# Pre-Frontal Motor activation: Reward with Friend v Stranger, zstat 9 cluster 2 (reward sensitivity) activation model exploratory result
model14 <- lm(`act_C13_rew-pun_F-C_z9_rs-neg_cluster2_type-act_cope-13` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model14)
crPlots(model14, smooth=FALSE)

# Frontal Pole activation: Reward with Friend v Stranger, zstat 10 (reward sensitivity squared) activation model exploratory result - interaction with substance use
model15 <- lm(`act_C13_rew-pun_F-C_z10_rs2-neg_type-act_cope-13` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model15)
crPlots(model15, smooth=FALSE)

# IMPORTANT - Reward with Friend v Stranger, zstat 2 (substance use) activation model exploratory result
model16 <- lm(`act_C14_rew_F-S_z2_sub_type-act_cope-14` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model16
summary(model16)

scatter <- ggplot(data = total, aes(x=SU,
                                    y=`act_C14_rew_F-S_z2_sub_type-act_cope-14`))+
  geom_smooth(method=lm, level = 0.99, 
              se=TRUE, fullrange=TRUE, color="black")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))

#pTPJ ROI multiple regressions

model20 <- lm(`pTPJ_R_P_F_C` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=total)
model20
crPlots(model20, smooth=FALSE)
summary(model20)

model21 <- lm(`pTPJ_R_P_F_S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=total)
summary(model21)
scatter <- ggplot(data = total, aes(x=SU,
                                    y=`pTPJ_R_P_F_S`))+
  geom_smooth(method=lm, level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed",)+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))
#reward vs punishment in social closeness condition is moderated by substance use - t = 2.482, p = 0.0177


#VS results

#exploratory - regression with VS wholebrain finding for Reward with Friend v Stranger
model22 <- lm(`act_c14_VS-wholebrain_rew-F-S_zstat1_cluster1` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model22
summary(model22)

#VS ROI findings
  #Reward Sensitivity finding
model23 <- lm(`act_VS-seed_11-rew-pun_F-S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model23
VS_RS_r <- cor(sharedreward$RS, sharedreward$`act_VS-seed_11-rew-pun_F-S`, method = 'pearson')
print(VS_RS_r)
summary(model23)
crPlots(model23, smooth=FALSE, grid=FALSE)
                #difference in VS activity for rew vs pun in friends vs strangers went down as reward sensitivity went up - p = 0.04717, t = -2.053
scatter <- ggplot(data = total, aes(x=RS,
                                    y=`act_VS-seed_11-rew-pun_F-S`))+
  geom_smooth(method=lm, level = 0.99, 
              se=TRUE, fullrange=TRUE, color="black")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))
  #Substance Use finding
model24
summary(model24)
crPlots(model24, smooth=FALSE, grid=FALSE)
                #difference in VS activity for rew vs pun in friends vs computers went down as substance use went up - p = 0.0271, t = -2.301
  #Substance Use finding
model28 <- lm(`act_VS-seed_23-rew-pun_F-SC` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model28
summary(model28)
crPlots(model28, smooth=FALSE, grid=FALSE)
                #difference in VS activity for rew vs pun in friends vs strangers & computers went down as substance use went up - p = 0.04945, t = -2.031


#ANOVA for VS_ROI - repeated measures
res.aov <- anova_test(
  data = df_VS_ROI, dv = Betas, wid = sub,
  within = c(Partner, Outcome)
)
get_anova_table(res.aov)

pair<-df_VS_ROI %>% 
  pairwise_t_test(Betas~Partner2,paired=TRUE, p.adjust.method = "bonferroni" ) 
data.frame(pair)

pwc <- df_VS_ROI %>%
  group_by(Outcome) %>%
  pairwise_t_test(
    Betas ~ Partner, paired = TRUE,
    p.adjust.method = "fdr"
  )
data.frame(pwc)

#ANOVA for VS_TPJ_ROI - repeated measures
#model30 <- aov(Betas ~ Partner + Outcome, data = df_VS_TPJ_ROI)
res.aov <- anova_test(
  data = df_VS_TPJ_ROI, dv = Betas, wid = sub,
  within = c(Partner, Outcome)
)
get_anova_table(res.aov)

pwc <- df_VS_TPJ_ROI %>%
  group_by(Outcome) %>%
  pairwise_t_test(
    Betas ~ Partner, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
data.frame(pwc)