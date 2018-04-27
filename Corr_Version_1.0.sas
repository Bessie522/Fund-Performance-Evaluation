



ods trace on;
ods output PearsonCorr=PortfolioCorr;
proc corr data=corr;
  var LFCTA	IdxArb	LTCTA	Alpha;                             /*��ߵĲ������ƿ��Ը���ʵ����������͸�д*/
  title;
run;
ods trace off;
ods output close;


proc export data=PortfolioCorr
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\PortfolioCorr-Portfolio.xls'
dbms=excelcs replace;
sheet='PortfolioCorr';
run;
