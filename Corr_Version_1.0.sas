



ods trace on;
ods output PearsonCorr=PortfolioCorr;
proc corr data=corr;
  var LFCTA	IdxArb	LTCTA	Alpha;                             /*这边的参数名称可以根据实际情况调整和改写*/
  title;
run;
ods trace off;
ods output close;


proc export data=PortfolioCorr
outfile='D:\AstroInvest Files\03_自营产品\评测后数据\ANALIZED_DATA\ANALIZED\PortfolioCorr-Portfolio.xls'
dbms=excelcs replace;
sheet='PortfolioCorr';
run;
