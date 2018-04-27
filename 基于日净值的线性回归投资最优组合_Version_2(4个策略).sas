

data portfolio;
  set portfolio;
  format date yymmdd10.        /*修改原数据的时间格式*/
;
    proc sort;                       /*数据集按照默认的升序进行排列*/
    by date;
run;




/*********************************************************************/
/*先算出每个策略的Sharpe*/
/*********************************************************************/
                                /*stockindex策略=strategyone*/
data strategyone;
  set portfolio;
  keep date strategyone;
run;
data strategyone1;
  set strategyone;
    cumstrategyone+strategyone;
	DLValue=cumstrategyone+1;
run;
proc sql;
  create table strategyone_first as select * from strategyone1 where date=(select min(date) from strategyone1);
  create table strategyone_end as select * from strategyone1 where date=(select max(date) from strategyone1);
run;
quit;
data strategyone2;
  set strategyone_first strategyone_end;
run;
data strategyone_stat;
  set strategyone2;
  NetValue_StraOne=((DLValue-lag(DLValue))/lag(DLValue))+1;                             /*累计净值*/
  NumDate_StraOne=(date-lag(date))-((date-lag(date))/30*10);                              /*运行天数*/
  YrRtn_StraOne=(NetValue_StraOne**(250/NumDate_StraOne))-1;                                                  /*年化收益率*/
  if _n_=1 then delete;
  keep NetValue_StraOne Numdate_StraOne YrRtn_StraOne;
run;
proc means data=strategyone std noprint;
  var strategyone;
  output out=straone_std;
  title;
run;
data straone_std1;
  set straone_std;
  keep _stat_ strategyone;
run;
data straone_std2;
  set straone_std1;
  where _stat_='STD';
  keep strategyone;
  rename strategyone=Std_StraOne;                                                         /*得出日收益率的波动率STD*/
run;
data strategyone_stat2;
  merge strategyone_stat straone_std2;
run;
data strategyone_stat3;
  set strategyone_stat2;
  Sharpe_StraOne=YrRtn_StraOne/Std_StraOne;                                                      /*得出Sharpe*/
run;






                                            /*cta日内策略=strategytwo*/
data strategytwo;
  set portfolio;
  keep date strategytwo;
run;
data strategytwo1;
  set strategytwo;
    cumstrategytwo+strategytwo;
	DLValue=cumstrategytwo+1;
run;
proc sql;
  create table strategytwo_first as select * from strategytwo1 where date=(select min(date) from strategytwo1);
  create table strategytwo_end as select * from strategytwo1 where date=(select max(date) from strategytwo1);
run;
quit;
data strategytwo2;
  set strategytwo_first strategytwo_end;
run;
data strategytwo_stat;
  set strategytwo2;
  NetValue_StraTwo=((DLValue-lag(DLValue))/lag(DLValue))+1;                             /*累计净值*/
  NumDate_StraTwo=(date-lag(date))-((date-lag(date))/30*10);                              /*运行天数*/
  YrRtn_StraTwo=(NetValue_StraTwo**(250/NumDate_StraTwo))-1;                                                  /*年化收益率*/
  if _n_=1 then delete;
  keep NetValue_StraTwo Numdate_StraTwo YrRtn_StraTwo;
run;
proc means data=strategytwo std noprint;
  var strategytwo;
  output out=stratwo_std;
  title;
run;
data stratwo_std1;
  set stratwo_std;
  keep _stat_ strategytwo;
run;
data stratwo_std2;
  set stratwo_std1;
  where _stat_='STD';
  keep strategytwo;
  rename strategytwo=Std_StraTwo;                                                         /*得出日收益率的波动率STD*/
run;
data strategytwo_stat2;
  merge strategytwo_stat stratwo_std2;
run;
data strategytwo_stat3;
  set strategytwo_stat2;
  Sharpe_StraTwo=YrRtn_StraTwo/Std_StraTwo;                                                      /*得出Sharpe*/
run;







                                                       /*cta长线策略=strategythree*/
data strategythree;
  set portfolio;
  keep date strategythree;
run;
data strategythree1;
  set strategythree;
    cumstrategythree+strategythree;
	DLValue=cumstrategythree+1;
run;
proc sql;
  create table strategythree_first as select * from strategythree1 where date=(select min(date) from strategythree1);
  create table strategythree_end as select * from strategythree1 where date=(select max(date) from strategythree1);
run;
quit;
data strategythree2;
  set strategythree_first strategythree_end;
run;
data strategythree_stat;
  set strategythree2;
  NetValue_StraThree=((DLValue-lag(DLValue))/lag(DLValue))+1;                             /*累计净值*/
  NumDate_StraThree=(date-lag(date))-((date-lag(date))/30*10);                              /*运行天数*/
  YrRtn_StraThree=(NetValue_StraThree**(250/NumDate_StraThree))-1;                                      /*年化收益率*/
  if _n_=1 then delete;
  keep NetValue_StraThree Numdate_StraThree YrRtn_StraThree;
run;
proc means data=strategythree std noprint;
  var strategythree;
  output out=strathree_std;
  title;
run;
data strathree_std1;
  set strathree_std;
  keep _stat_ strategythree;
run;
data strathree_std2;
  set strathree_std1;
  where _stat_='STD';
  keep strategythree;
  rename strategythree=Std_StraThree;                                                         /*得出日收益率的波动率STD*/
run;
data strategythree_stat2;
  merge strategythree_stat strathree_std2;
run;
data strategythree_stat3;
  set strategythree_stat2;
  Sharpe_StraThree=YrRtn_StraThree/Std_StraThree;                                                      /*得出Sharpe*/
run;








                                                      /*alpha中性策略=strategyfour*/
data strategyfour;
  set portfolio;
  keep date strategyfour;
run;
data strategyfour1;
  set strategyfour;
    cumstrategyfour+strategyfour;
	DLValue=cumstrategyfour+1;
run;
proc sql;
  create table strategyfour_first as select * from strategyfour1 where date=(select min(date) from strategyfour1);
  create table strategyfour_end as select * from strategyfour1 where date=(select max(date) from strategyfour1);
run;
quit;
data strategyfour2;
  set strategyfour_first strategyfour_end;
run;
data strategyfour_stat;
  set strategyfour2;
  NetValue_StraFour=((DLValue-lag(DLValue))/lag(DLValue))+1;                             /*累计净值*/
  NumDate_StraFour=(date-lag(date))-((date-lag(date))/30*10);                              /*运行天数*/
  YrRtn_StraFour=(NetValue_StraFour**(250/NumDate_StraFour))-1;                                      /*年化收益率*/
  if _n_=1 then delete;
  keep NetValue_StraFour Numdate_StraFour YrRtn_StraFour;
run;
proc means data=strategyfour std noprint;
  var strategyfour;
  output out=strafour_std;
  title;
run;
data strafour_std1;
  set strafour_std;
  keep _stat_ strategyfour;
run;
data strafour_std2;
  set strafour_std1;
  where _stat_='STD';
  keep strategyfour;
  rename strategyfour=Std_StraFour;                                                         /*得出日收益率的波动率STD*/
run;
data strategyfour_stat2;
  merge strategyfour_stat strafour_std2;
run;
data strategyfour_stat3;
  set strategyfour_stat2;
  Sharpe_StraFour=YrRtn_StraFour/Std_StraFour;                                                      /*得出Sharpe*/
run;






                                                                       /*汇总收益率*/
data YrRtn_Strategy;
  merge strategyone_stat3 strategytwo_stat3 strategythree_stat3 strategyfour_stat3;
  keep YrRtn_StraOne YrRtn_StraTwo YrRtn_StraThree YrRtn_StraFour;
run;

                                                                              /*汇总Sharpe*/
data Sharpe_Strategy;
  merge strategyone_stat3 strategytwo_stat3 strategythree_stat3 strategyfour_stat3;
  keep Sharpe_StraOne Sharpe_StraTwo Sharpe_StraThree Sharpe_StraFour;
run;

                                                                                   /*汇总波动率*/
data Std_Strategy;
  merge strategyone_stat3 strategytwo_stat3 strategythree_stat3 strategyfour_stat3;
  keep Std_StraOne Std_StraTwo Std_StraThree Std_StraFour;
run;










/************************************************************************/
/*用Sharpe值来计算最优权重配比*/
/************************************************************************/

data weight1;
input _id_: $10. Sharpe_StraOne Sharpe_StraTwo Sharpe_StraThree Sharpe_StraFour _type_ $ _rhs_;
cards;
object 37.620199944 54.212870329 34.097058269 24.270543239 max .
yrrtn 0.2877190342 0.2358192456 0.1813324463 0.161641394 max .
std 0.0076479932 0.0043498757 0.0053181258 0.0066599825 min .
sum_wts 1.0 1.0 1.0 1.0 eq 1.0
available 0.3999 0.3999 0.3999 0.3999 upperbd .
available 0.1999 0.1999 0.1999 0.1999 lowerbd .
;
run;

proc lp data=weight1 primalout=lp_out1;
title "最优投资组合权重";
run;
quit;




data weight2;
input _id_: $10. Sharpe_StraOne Sharpe_StraTwo Sharpe_StraThree Sharpe_StraFour _type_ $ _rhs_;
cards;
object 37.620199944 54.212870329 34.097058269 24.270543239 min.
yrrtn 0.2877190342 0.2358192456 0.1813324463 0.161641394 max .
std 0.0076479932 0.0043498757 0.0053181258 0.0066599825 min .
sum_wts 1.0 1.0 1.0 1.0 eq 1.0
available 0.2999 0.2999 0.2999 0.2999 upperbd .
available 0.0999 0.0999 0.0999 0.0999 lowerbd .
;
run;

proc lp data=weight2 primalout=lp_out2;
title "多约束的投资组合权重";
run;
quit;


proc lp data=weight2 primalin=lp_out2 rangeprice rangerhs;
title "灵敏度分析";
run;
quit;



data lp_out2a;
set lp_out2;
if _n_>4 then delete;
amount=_value_*50000000;
rename _var_=asset;
proc print data=lp_out2a;
var asset amount;
title '线性规划';
title2 '在每种资产上的投资金额';
run;

























/*********************************************/
/*样例****************************************/
/********************************************/

/*proc lp data=weight1 primalin=lp_out1;
title1 '最优投资组合权重';
run;
quit; 


data weight2;
input _id_: $10. lg bh hb hx fh _type_ $ _rhs_;
cards;
exp_return 0.2268 0.1963 0.1304 0.1533 0.4198 max
beta -2.2168 0.1231 0.1586 1.6453 0.9582 eq 1.3
sum_wts   1.0 1.0 1.0 1.0 1.0 eq 1.0
available 0.3 0.3 0.3 0.2 0.3 upperbd.
available  0.1 0.1 0.1 0.1 0.1 lowerbd.
;
run;

proc lp data=weight2 primalout=lp_out2;
title1 '多约束的最优投资组合权重';
run;
quit; 


proc lp data=weight2 primalout=lp_out2 rangeprice rangerhs;
title2 '灵敏度分析';
run;
quit; 



data weight3;
set weight2;
if _id_='beta'  then  _type_='le';
run;
proc lp data=weight3 primalout=lp_out3;
run;
quit;


data lp_out3a;
set lp_out2;
if _n_>5 then delete;
amount=_value_*50000000;
rename _var_=asset;
proc print data=lp_out3a;
var asset amount;
title '线性规划';
title2 '在每种资产上的投资金额';
run;*/
