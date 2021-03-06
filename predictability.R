library('ncdf4')
library(extRemes)
library(scatterplot3d)

#Open the extremes
dir='//home/timok/timok/SALIENSEAS/SEAS5'
nc=nc_open(paste0(dir,'/ensex/Extremes/Extremes.nc'))#for lonlat
nc_sv=nc_open(paste0(dir,'/ensex/Extremes/Extremes_SV.nc'))#for lonlat

Extremes_WC=ncvar_get(nc)
Extremes_SV=ncvar_get(nc_sv)
# Extremes_SV
dim(Extremes_WC) # 25 4 35 Ensemble Leadtime Year 

#There is an error that the dimnames do not get saved from Xarray to_netcdf. Set the dimnames here 
dimnames(Extremes_WC) = list(as.character(0:24),as.character(2:5),as.character(1981:2015))
dimnames(Extremes_SV) = list(as.character(0:24),as.character(2:5),as.character(1981:2015))

Extremes_array= Extremes_SV# Note to self: previously was 4 25 35

#We want to know the potential predictability, the ability of the model to predict itself.
#We want to predict one of the ensemble members with the rest of the ensemble members
#Objective criteria is the anomaly correlation
#REVISED: to test the correlation, we do a pairwise test between all ensemble members, rather than the mean
predictant=as.vector(Extremes_array[1,'2',]) #First member, first leadtime that we use in this study
predictor=as.vector(Extremes_array[2,'2',]) #Second member, first leadtime that we use in this study
# predictor=as.vector(apply(Extremes_array[-1,'2',],FUN = mean , MARGIN=c(2)))

#Standarized anomaly
predictant_anomaly=(predictant-mean(predictant))/sd(predictant)
predictor_anomaly=(predictor-mean(predictor))/sd(predictor)

#Use spearman to avoid normality assumptions
cor_coeff='spearman'
correlation=cor.test(predictant_anomaly,predictor_anomaly,alternative = 'two.sided',method = cor_coeff) #alternative hypothesis is that the population correlation is greater than 0. -> we don't expect negative correlations? 
# correlation$p.value
# correlation$estimate

png(paste0('//home/timok/timok/SALIENSEAS/SEAS5/ensex/statistics/multiday/plots/Predictability_SV.png'),type='cairo')
par(mar=c(4.5,5.1,2.1,2.1),cex.axis=1.5, cex.lab=1.5,cex.main=1.5)
plot(predictant_anomaly,predictor_anomaly, xlim=c(min(predictor_anomaly,predictant_anomaly),max(predictor_anomaly,predictant_anomaly)),ylim=c(min(predictor_anomaly,predictant_anomaly),max(predictor_anomaly,predictant_anomaly)),
     xlab='Standardized anomaly member 00', ylab='Standardized anomaly member 01')
lines(c(-5,5),c(-5,5))
text(0.4*min(predictor_anomaly,predictant_anomaly),0.8*max(predictor_anomaly,predictant_anomaly),
     bquote(atop("Spearman" ~ r== .(round(correlation$estimate,digits = 3)),
                 'p value' == .(round(correlation$p.value,digits = 3)))),cex=1.3)
# text(0.4*min(predictor_anomaly,predictant_anomaly),0.8*max(predictor_anomaly,predictant_anomaly),
#      atop(parse(text = paste(' Spearman ~ r^2 ==', round(correlation$estimate,digits = 3))),
#           parse(text = paste('p value ==', round(correlation$p.value,digits = 3)))),cex=1.3)
legend("bottomright", legend=c("1:1 line"),lty=1,cex=1.3)
dev.off()



correlations_lds=array(dim = c(25,25,4),dimnames = list(as.character(0:24),as.character(0:24),as.character(2:5))) #lds, mbmrs
for (ld in 2:5){
  for (mbr1 in 1:25){
    for (mbr2 in 1:25){
        
      if (mbr1>mbr2){
        predictant=as.vector(Extremes_array[mbr1,as.character(ld),])
        predictor=as.vector(Extremes_array[mbr2,as.character(ld),])
        # predictor=as.vector(apply(Extremes_array[-mbr,as.character(ld),],FUN = mean , MARGIN=c(2)))
        
        predictant_anomaly=(predictant-mean(predictant))/sd(predictant)
        predictor_anomaly=(predictor-mean(predictor))/sd(predictor)
        
        correlations_lds[mbr1,mbr2,as.character(ld)]=cor(predictant_anomaly,predictor_anomaly,method = cor_coeff)
      }
    }
  }
}

#Check
# correlations_lds[2,1,'2']==correlation$estimate

png(paste0('//home/timok/timok/SALIENSEAS/SEAS5/ensex/statistics/multiday/plots/Predictability_lds_SV.png'),type='cairo')
par(mar=c(4.5,5.1,2.1,2.1),cex.axis=1.5, cex.lab=1.5,cex.main=1.5)
boxplot(list(correlations_lds[,,'2'],correlations_lds[,,'3'],correlations_lds[,,'4'],correlations_lds[,,'5']),
        xaxt="n",xlab='Lead time',ylab=bquote('Spearman'~r))
# lines(0:6,rep(0.114,7))
# text(1,0.12,bquote('threshold'~r),cex=1.3)
Axis(side=1,at=1:5,labels = c(as.character(2:5),'all'))
dev.off()


#Bootstrap

  Bootstrap <- function(Extremes_array) {
    # Quantiles_fun <- function(x) {  quantile(x,Quantiles,na.rm=T)}
    Boxplot_fun <- function(x) {  
      }
    
    Extremes_resampled=sample(x=Extremes_array, size=3500, replace = FALSE)
    Extremes_array_resampled=array(Extremes_resampled,dim = c(25,4,35),dimnames = list(as.character(0:24),as.character(2:5),as.character(1981:2015)))
    
    predictant=as.vector(Extremes_array_resampled[1,'2',]) #First member, first leadtime that we use in this study
    predictor=as.vector(Extremes_array_resampled[2,'2',]) #Second member, first leadtime that we use in this study
    # predictor=as.vector(apply(Extremes_array[-1,'2',],FUN = mean , MARGIN=c(2)))
    
    #Standarized anomaly
    predictant_anomaly=(predictant-mean(predictant))/sd(predictant)
    predictor_anomaly=(predictor-mean(predictor))/sd(predictor)
    
    #Use spearman to avoid normality assumptions
    cor_coeff='spearman'
    correlation=cor.test(predictant_anomaly,predictor_anomaly,alternative = 'two.sided',method = cor_coeff) #alternative hypothesis is that the population correlation is greater than 0. -> we don't expect negative correlations? 
    correlation$p.value
    correlation$estimate
    
    correlations_lds_resampled=array(dim = c(25,25,4),dimnames = list(as.character(0:24),as.character(0:24),as.character(2:5))) #lds, mbmrs
    for (ld in 2:5){
      for (mbr1 in 1:25){
        for (mbr2 in 1:25){
          
          if (mbr1>mbr2){
            predictant=as.vector(Extremes_array_resampled[mbr1,as.character(ld),])
            predictor=as.vector(Extremes_array_resampled[mbr2,as.character(ld),])
            # predictor=as.vector(apply(Extremes_array[-mbr,as.character(ld),],FUN = mean , MARGIN=c(2)))
            
            predictant_anomaly=(predictant-mean(predictant))/sd(predictant)
            predictor_anomaly=(predictor-mean(predictor))/sd(predictor)
            
            correlations_lds_resampled[mbr1,mbr2,as.character(ld)]=cor(predictant_anomaly,predictor_anomaly,method = cor_coeff)
          }
        }
      }
    }
    a=boxplot(list(correlations_lds_resampled[,,'2'],correlations_lds_resampled[,,'3'],correlations_lds_resampled[,,'4'],
                   correlations_lds_resampled[,,'5']), plot = F)
           return(a$stats)
  }
  
  
# Quantiles=c(0.015,0.25,0.5,0.75,0.985)
correlations_lds_bootstrapped=replicate(1000,Bootstrap(Extremes_array))

Quantiles=c(0.025,0.975)
Quantiles_fun <- function(x) {quantile(x,Quantiles,na.rm=T)}
CI_bounds_boxplots=apply(correlations_lds_bootstrapped[,,], MARGIN = 1,Quantiles_fun ) #We resample 1000 times for 4 leadtimes. Resulting in 4000 quantiles based on 300 pairs of correlations. 

png(paste0('//home/timok/timok/SALIENSEAS/SEAS5/ensex/statistics/multiday/plots/Predictability_lds_resampled_SV.png'),type='cairo')
par(mar=c(4.5,5.1,2.1,2.1),cex.axis=1.5, cex.lab=1.5,cex.main=1.5)
boxplot(list(correlations_lds[,,'2'],correlations_lds[,,'3'],correlations_lds[,,'4'],correlations_lds[,,'5']),
        xaxt="n",xlab='Lead time',ylab=bquote('Spearman'~r))
for (i in 1:length(CI_bounds_boxplots[1,]))  {
  polygon(c(0,6,6,0),c(rep(CI_bounds_boxplots[1,i],2),rep(CI_bounds_boxplots[2,i],2)),col=gray(0.8,alpha=0.3))}
  # lines(0:6,rep(CI_bounds_boxplots[1,i],7))
  # text(1,CI_bounds_boxplots[1,i],bquote('threshold'~r),cex=1.3)
  # lines(0:6,rep(CI_bounds_boxplots[2,i],7))
  # text(1,CI_bounds_boxplots[2,i],bquote('threshold'~r),cex=1.3)
  # }
Axis(side=1,at=1:5,labels = c(as.character(2:5),'all'))
dev.off()

