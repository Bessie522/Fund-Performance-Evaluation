

/*�����ۼƾ�ֵ���������������㣬����մ��ۼƾ�ֵ���ۼ������ʡ����س�*/
data parfdval;
  set parfdval;
    format date yymmdd10.        /*�޸�ԭ���ݵ�ʱ���ʽ*/
;
    proc sort;                       /*���ݼ�����Ĭ�ϵ������������*/
    by date;
run;
data pardata1;
  set parfdval;
    drate=dval/lag(dval)-1;          /*dval��ָ�մ��ۼƾ�ֵ*/
run;
	/*ȡdval�ĵ�һ��ֵ��Ϊ���ۼ������ʵķ�ĸ*/
data pardata2;
  set pardata1;
    retain fdval;
    if _N_=1 then fdval=dval;
      else cumdval=dval/fdval-1;                /*cumdvalΪ�ۼ�������*/
run;
	  /*������ʷ���س�*/
data pardata3;
  set pardata2;
  retain max_value;                                   /*retain�趨�ı�������ȥ�޸ģ����Ǳ���ǰֵ*//*retianĬ��ϵͳ��Сֵ*/
  if max_value < dval then max_value = dval;
  maxdraw = dval/max_value-1;
run;




/*���մ�������ȡ��������ֵ����׼��ղ����ʣ���ƫ�ȡ���ֵ*/
proc means data=pardata3 mean std median skew kurt noprint;
  var drate;
  output out=dratestat(keep=_stat_ drate);
  title;
run;
data dratestat;
  set dratestat(rename=(_stat_=stat));
run;
proc sql;
create table dstd as select drate from dratestat where stat='STD';
run;
quit;
data dstd;                            /*�ղ����ʣ���׼�*/
  set dstd(rename=(drate=dstd));
run;





/*����ͳ��summary*/
proc sql;
create table summary1 as select * from pardata3 where date=(select min(date) from pardata3);
create table summary2 as select * from pardata3 where date=(select max(date) from pardata3);
run;
quit;
data summary;
  set summary1 summary2;
run;
/*���ʹ�õ�ͳ������*/
data stat;
  set summary;
  ljjz=((dval-lag(dval))/lag(dval))+1;                             /*�ۼƾ�ֵ*/
  yxts=date-lag(date);                                                 /*��������*/
  yfrate=0.0246;                                                          /*ָ���껯�޷���������*/
  dfrate=(1+yfrate)**(1/250)-1;                                                 /*�ջ��޷���������*/
  yprorate=(ljjz**(365/yxts))-1;                                                  /*�껯������*/
  dprorate=((1+yprorate)**(1/250))-1;                                                    /*�ջ�������*/
  drop date dval drate fdval cumdval max_value maxdraw;
run;
  /*��end����������һ����¼*/
data stat;
  set stat end=lastrec;
  if lastrec;
run;
/*�������ϵ��*/
data stat;
  merge stat dstd;                                                 /*�ղ�����*/
run;
data stat;
  set stat;
  dlcxs=abs(dstd/dprorate);                                                  /*�����ϵ��*/
  drop dstd;
run;




/*�����ʤ��*/
data weekday;
  set pardata1;
  weekday=weekday(date);                         /*��weekday������weekday��������ֵ������Ϊ1���Դ�����*/
run;
proc sql;
create table weekrate as select date,dval from weekday where weekday=6;          /*ѡ��ÿ������������Ӧ���վ�ֵ*/
run;
quit;
data wrate;
  set weekrate;
  wrate=dval/lag(dval)-1;                              /*����ܴ��վ�ֵ����*/
run;
proc sql;
create table weekwin1 as select count(wrate) as couwwin from wrate where wrate>0;         /*�ҳ��ܴ�������Ϊ��������*/
run;
quit;
proc sql;
create table weekwin2 as select count(wrate) as couweek from wrate;                              /*�ܴ������ʵ�������*/
run;
quit;
data weekwin;
  merge weekwin1 weekwin2;
run;
quit;
data weekwin;
  set weekwin;
  wwinrate=couwwin/couweek;                                  /*�ϲ��Ժ�����ܴ�ʤ����*/
run;
data stat;
  set stat;
  merge stat weekwin;
  drop couwwin couweek;                                                                 /*��ʤ����*/
run;




/*�����������������������µ�����*/
/*���������ǻ����µ�����������*/
data max_week;                                    /*�������ǡ��µ�����*/
  set wrate(keep=wrate);
  retain n 0;
  if wrate > 0 then if n > 0 then  n=n+1;
            else n=1;
  if wrate=0 then  n=0;
  if wrate < 0 then if n < 0 then n=n-1;
                        else n=-1;
run;
proc means data=max_week max min noprint;
  var n;
  output out=rdweek(drop=_TYPE_ _FREQ_ rename=(_STAT_=stat));
  title;
run;
proc sql;
create table max_rweek as select n as max_rweek from rdweek where stat='MAX';
create table max_dweek as select n as max_dweek from rdweek where stat='MIN';
run;
quit;
data max_rdweek;
  merge max_rweek max_dweek;
run;
data stat;
  merge stat max_rdweek;
run;





/*���㵥�����ӯ����������*/
proc means data=pardata1 max min noprint;
  var drate;
  output out=maxwl_drate(drop=_TYPE_ _FREQ_ rename=(_STAT_=stat));
  title;
run;
proc sql;
create table max_drate as select drate as max_drate from maxwl_drate where stat='MAX';                   /*�����ӯ��*/
create table maxl_drate as select drate as maxl_drate from maxwl_drate where stat='MIN';                        /*����տ���*/
run;
quit;
data max_drate;
  merge max_drate maxl_drate;
run;
data stat;
  merge stat max_drate;
run;




/*��ʷ���س����������س�*/
proc means data=pardata3 max min noprint;
  var maxdraw;
output out=max_draw(drop=_TYPE_ _FREQ_ rename=(_STAT_=stat));
title;
run;
proc sql;
create table maxl_draw as select maxdraw as maxl_draw from max_draw where stat='MIN';                                   /*��ʷ���س�*/
run;
quit;
proc means data=pardata1 min noprint;
  var drate;
  output out=min_drate(drop=_TYPE_ _FREQ_ rename=(_STAT_=stat));
  title;
run;
proc sql;
create table minl_drate as select drate as minl_drate from min_drate where stat='MIN';                        /*����տ���*/
run;
quit;
data stat;
  merge stat maxl_draw minl_drate;                                                                       /*�ϲ���ʷ���س����������س�*/
run;





/*��ʷ���س��ָ�ʱ��*/
data rec_maxdraw;
  set pardata3(keep=date max_value maxdraw);                      
run;
proc sql;
create table rec_num as select * from rec_maxdraw having maxdraw=min(maxdraw);     /*ֻ�������س�*/
run;
quit;
proc sql;
create table maxdate_num as select * from rec_maxdraw having date=max(date);     /*ֻ�����������*/
run;
quit;
proc sql;
create table zero_num as select * from rec_maxdraw where maxdraw=0;                     /*ѡ�����лس�Ϊ0��*/
run;
quit;
data recnum;
  set rec_num maxdate_num zero_num;
  proc sort data=recnum;
  by date;                                                                           /*�����ݼ������Ұ���ʱ�����򣬽����س��Ż����س�Ϊ0��ʱ����*/
run;
proc sort data=recnum dupout=nodups3 nodupkey;
  by date;
run;
data recnum;
  set recnum;
  n=date-lag(date);                                                               /*����һ��ʱ�����ڼ���һ��ʱ�����ڣ����Եõ����س��ָ����Ӹ���*/
run;
data recnum;
  set recnum;
  if _n_=2 then wnum=lag(maxdraw);else wnum=lag(maxdraw);                       /*��������sum�������س��˻�һ����ö�Ӧ���س�����*/
run;
proc sql;
create table rec_week_num as select * from recnum as b having b.wnum=min(wnum);        /*ֻ�Ѱ������س�ֵ��һ�б�������*/
run;
quit;
data recwnum(keep=recwnum);
  set rec_week_num end=lastrec;                                                            /*��end�������ݼ������һ���۲�ֵ*/
  if lastrec then recwnum=n/7;                                                                   /*�ó����س�week*/
run;
data recwnum;
  set recwnum end=lastrec;
  if lastrec;
run;
/*�ϲ����س��ָ�ʱ��*/
data stat;
  set stat;
  merge recwnum;
run;




/*�ϲ��ղ����ʡ��껯�����ʡ��껯���ϵ��*/
data stat;
  set stat;
  merge stat dstd;
  ystd=dstd*sqrt(250);                /*�껯������*/
  ylcxs=abs(ystd/yprorate);               /*�껯���ϵ��*/
run;



/*�껯���б�׼��*/
data ddex1;
  set pardata2(keep=drate);
  if drate=. then delete;
run;
data ddex2;
  set stat(keep=dprorate);
run;
data ddex(drop=dprorate);
  merge ddex1 ddex2;
  retain dpr;                                                                       /*�ջ�������*/
  if _n_=1 then dpr=dprorate;
run;
data ddex;
  set ddex;
  diffdrate=drate-dpr;                                                                  /*�մ�������-�ջ�������*/
run;
proc sql;
create table minddex as select diffdrate from ddex where diffdrate < 0;
run;
quit;
data minddex;
  set minddex;
  exp=diffdrate*diffdrate;                                                                 /*�����ջ�������ƽ��*/
run;
proc sql;
create table sumddex as select sum(exp) as sumddex from minddex;
run;
quit;
proc sql;
create table countddex as select count(diffdrate) as countddex from ddex;
run;
quit;
data countddex;
  set countddex;
  countddex=countddex-1;                                                                          /*����sample����������Ҫn-1*/
run;
data ddstd;
  merge sumddex countddex;
  yddstd=sqrt(sumddex/countddex)*sqrt(250);                                                               /*���б�׼��*/
run;
data stat;
  set stat;
  merge stat ddstd(drop=sumddex countddex);
run;





/*���ձ��ʡ�sortino���ʡ�calmar����*/
data stat;
  set stat;
  sharp=(yprorate)/ystd;       /*���ձ���*//*û�м�ȥ�޷�������*/
  sortino=(yprorate)/yddstd;     /*sortino����*//*û�м�ȥ�޷�������*/
  calmar=yprorate/abs(maxl_draw);          /*calmar����*/
run;






                                                                    /*��log����ʾͳ�ƽ����name*/

ods trace on;
proc means data=pardata3 mean std stderr uclm lclm n skew kurt;
  var drate;
  output out=sumdratestat;
  title;
run;
quit;
ods trace off;
data drate;
  set pardata3;
  keep drate;
  if drate=. then delete;
run;  

                                                                /*��������ڵ�ͳ�ƽ����ODS��������ݼ���*/
                                                    /*�ر�ͳ�������б��������*/

ods output summary=sumdratestat;
proc means data=drate mean std stderr uclm lclm n skew kurt;
  var drate;
  title;
run;
quit;
ods output close;                                
                                                           /*���´�ͳ�������б��������*/

                                                                               /*��ODS��������ݼ�����ת��*/
proc transpose data=sumdratestat out=sumdratestat;run;



/**************************************************************************************************/
/*fitcurve��fithistogram��fitpplotͼHTML���*/

/*�����մ������ʵ������*/
data fitcurve(rename=(lagwrate=x wrate=y));
  set wrate(keep=wrate);
  if wrate=. then wrate=0;
  lagwrate=lag(wrate);
  if lagwrate=. then delete;
run;


                                                                           /*�������ͼ�ν��д��*/
/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\fitcurve-����.gif";         /*���ͼ����ڴ�·����*/                                                                                         
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/                                                                             
ods trace on;
ods output Nobs=nobs ANOVA=anova FitStatistics=fitstat ParameterEstimates=parest;
proc reg data=fitcurve gout=work.fitcurve;
model y=x;
plot y*x;
title;
run;
quit;
ods output close;
ods trace off;


ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED'(url=none) body='fitcurve.htm';
ods graphics on;
proc reg data=fitcurve gout=work.fitcurve;
model y=x;
plot y*x;
title "fitcurve";
run;quit;
ods html close;
ods listing;






                                                                                /*���ܴ������ʵĸ��ʷֲ�ͼ���д��*/
/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\fithistogram-����.gif";          /*������״ͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output TestsForNormality=normalfit Quantiles=quantfit;
proc univariate data=fitcurve normal gout=work.fithistogram;
var x;
histogram x/normal(color=red w=2);
title;
run;
quit;
ods output close;
ods trace off;


ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED'(url=none) body='fithistogram.htm';
ods graphics on;
proc univariate data=fitcurve normal gout=work.fithistogram;
var x;
histogram x/normal(color=red w=2);
title "fithistogram";
run;quit;
ods html close;
ods listing;






                                                                                    /*���ܴ������ʵİٷ�λͼ���д��*/

/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\fitpplot-����.gif";                  /*�ٷ�λPPͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED'(url=none) body='fitpplot.htm';
ods graphics on;
proc univariate data=fitcurve normal gout=work.fitpplot;
var x;
probplot x/normal(mu=est sigma=est);
title "fitpplot";
run;quit;
ods html close;
ods listing;















/********************************************/
/********************************************/
/*hurst��ʼ*/


data parfdval;
  set parfdval;
  format date yymmdd10.
  ;
proc sort;
by date;
run;

data index1;
set parfdval;
ret=100*(log(dval)-log(lag(dval))); format ret 8.5;
if _N_=1 then delete;
if _N_=1 then i=1;else i+1;
keep date dval ret i;
run;



data data11;
set index1;
j=int(i/7)+1;
run;
proc means data=data11 std  mean noprint;
var ret;
by j;
output out=data21(drop=_type_  _freq_)
       mean=junzhi
   std=bzc;
run;

proc sql;
create table data31 as 
select 
      a.*,
  b.junzhi,
  b.bzc

from data11 a,
     data21 b
where 
    a.j=b.j;
quit;

data data31;
set data31;
if ret=. then delete;
run;


data data41;
set data31;
retain licha;
by j;
if first.j then licha=ret-junzhi; else
                licha=licha+(ret-junzhi); 

retain maxlicha;
if first.j then maxlicha=licha;else 
           if maxlicha<licha then maxlicha=licha;
retain mixlicha;
if first.j then mixlicha=licha ;else 
           if mixlicha>licha then mixlicha=licha;
if last.j then  R=(maxlicha-mixlicha)/bzc; else 
          delete;
run;
data data41;
  set data41;
  if R=. then delete;
run;
data data41;
  set data41;
  retain SumR;
  if _n_=1 then SumR=R; else SumR=SumR+R;

  format licha mixlicha  maxlicha R SumR 12.5 ;
  *drop dval ret junzhi licha    mixlicha  maxlicha bzc ;
run;


data data51;
set data41;
AveR=SumR/j;
LogAveR=log(SumR/j);
logn=log(7);
n=7;
*stockcode="lgqq";
format logn LogAveR  AveR 8.5;
keep logn LogAveR n AveR;
run;

data hurstdata1;
  set data51;
run;

/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\fithurst--����.gif";                  /*hurstͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output ParameterEstimates=fithurst;
proc reg data=hurstdata1 gout=work.fithurst;
model LogAveR=logn;
plot LogAveR*logn;
title;
run;
quit;
ods output close;
ods trace off;



/**************************************************************************************************/
/*hurstͼHTML���*/

ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED'(url=none) body='fithurst.htm';
ods graphics on;
proc reg data=hurstdata1 gout=work.fithurst;
model LogAveR=logn;
plot LogAveR*logn;
title "fithurst";
run;
quit;
ods html close;
ods listing;







data hurst1;
  set fithurst;
  keep variable estimate;
  attrib _all_ label="";
  rename estimate=hurst;
run;


proc export data=hurst1                                              /*���hurst*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\hurst.xls' 
dbms=excelcs replace;
sheet='hurst';
run;





/*************************************************/
/*************************************************/
/*beta&alpha��ʼ*/


                                  /*���վ�ֵ���ݵ�date���и�ʽ����������date��������*/
data parfdval;
  set parfdval;
    format date yymmdd10.
;
run;
proc sort;
  by date;
run;

                                    /*����մ�������*/
data parfdval;
  set parfdval;
    drate=dval/lag(dval)-1;
run;

                                        /*ѡ����һ������һ���ֵ*/
proc sql;
create table fdval as select * from parfdval where date=(select min(date) from parfdval);
create table edval as select * from parfdval where date=(select max(date) from parfdval);
run;
quit;


data stat1;
  set fdval edval;
  keep date dval;
run;


                                               
data stat1;
  set stat1;
  ljjz=((dval-lag(dval))/lag(dval))+1;                   /*�ۼƾ�ֵ*/
  yxts=date-lag(date);                                      /*��������*/
  yfrate=0.0246;
  yprorate=(ljjz**(365/yxts))-1;                             /*�껯������*/
  *cesy=yprorate-yfrate;                                           /*��������*/
  keep ljjz yxts yfrate yprorate;
  if ljjz=. then delete;
run;


                                               /*����ͬ�ڵĻ���300���վ�ֵ����*/
data hsdval;
  set hsdval;
    format hsdate yymmdd10.
;
run;
proc sort;
by hsdate;
run;
data hsdval;
  set hsdval;
  hsdrate=(hsdval/lag(hsdval))-1;
run;

                                                   /*��������մ����������ݺͻ���300���������ݺϲ�*/
data fitparhs;
  merge parfdval hsdval;
  keep drate hsdrate;
  if drate=. then delete;
run;



/**************************************************************************************************/
/*betaalphaͼHTML���*/

/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\betaalpha--����.gif";                  /*betaalphaͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output ParameterEstimates=fit_parhs;
proc reg data=fitparhs gout=work.fit_parhs;
model drate=hsdrate;
plot drate*hsdrate;
title;
run;
quit;
ods output close;
ods trace off;


ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED'(url=none) body='betaalpha.htm';
ods graphics on;
proc reg data=fitparhs gout=work.fit_parhs;
model drate=hsdrate;
plot drate*hsdrate;
title "betaalpha";
run;
quit;
ods html close;
ods listing;




data fit_parhs;
  set fit_parhs;
  where variable='hsdrate';              /*��where����if������keep�ľ�������*/
  keep Variable Estimate;
run;


data beta(rename=(Estimate=beta));               /*��ȡbetaֵ*/
  set fit_parhs;
  keep Estimate;
  attrib _all_ label="";
run;


                                        /*ѡ����һ������һ���ֵ*/
proc sql;
create table fhsdval as select * from hsdval where hsdate=(select min(hsdate) from hsdval);
create table ehsdval as select * from hsdval where hsdate=(select max(hsdate) from hsdval);
run;
quit;


data hsstat;
  set fhsdval ehsdval;
  keep hsdate hsdval;
run;

                                                       /*ͬ�ڻ���300�վ�ֵ����*/
data hsstat;
  set hsstat;
  hsljjz=((hsdval-lag(hsdval))/lag(hsdval))+1;                   /*�ۼƾ�ֵ*/
  hsyxts=hsdate-lag(hsdate);                                         /*��������*/
  hsyprorate=(hsljjz**(365/hsyxts))-1;                                  /*�껯������*/
  keep hsljjz hsyxts hsyprorate;
  if hsljjz=. then delete;
run;


data stat1;
  merge stat1 hsstat beta;
run;


data stat1;
  set stat1;
    exp_return=(hsyprorate-yfrate)*beta;
	alpha=yprorate-exp_return;
run;


proc export data=stat1
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\betaalpha_stat.xls'
dbms=excelcs replace;
sheet='betaalpha';
run;





/*************************************************/
/*************************************************/
/*����ֵ�ʹ��̵�corr��ʼ*/

data fundhs_corr;
  merge parfdval hsdval;
  keep date dval hsdval;
run;

ods trace on;
ods output PearsonCorr=fundhscorr;
proc corr data=fundhs_corr;
  var dval hsdval;
  title;
run;
ods trace off;
ods output close;


proc export data=fundhscorr
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\betaalpha_stat.xls'
dbms=excelcs replace;
sheet='fundhscorr';
run;








/**************************************************************************************************/
/**************************************************************************************************/
/*�״�ͼ����*/
/*ѡȡ��Ҫ�Ž��״�ͼ��ָ��*/
/*ӯ������-�껯������
  �����ȶ���-���ϵ��
  ����������-hurstָ��
  ���沨����-�껯������+���б�׼��
  �س����-���س�+���س��ָ�ʱ��
  ����������-sharpe+sortino+calmar*/

data gradar;
  merge stat hurst1;
  if _n_>1 then delete;
  drop variable;
run;
data gradar1;
  set gradar;
  keep yprorate ylcxs hurst ystd yddstd maxl_draw recwnum sharp sortino calmar;
run;


data gradar2;
  set gradar1;
  rename yprorate=x1 ylcxs=x2 hurst=x3 ystd=x4 yddstd=x5 maxl_draw=x6 recwnum=x7 sharp=x8 sortino=x9 calmar=x10;
run;



                                                           /*��׼��10���ƣ�����10��ָ�꣬���д��*/
data gradar3;
  set gradar2;
  x1_std=((x1-0)/(0.5-0))*10;
  x2_std=((x2-5)/(0-5))*10;
  x3_std=((x3-0)/(1-0))*10;
  x4_std=((x4-0.5)/(0-0.5))*10;
  x5_std=((x5-0.5)/(0-0.5))*10;
  x6_std=((x6-(-0.15))/(0-(-0.15)))*10;
  x7_std=((x7-24)/(0-24))*10;
  x8_std=((x8-0)/(3-0))*10;
  x9_std=((x9-0)/(4-0))*10;
  x10_std=((x10-0)/(5-0))*10;
  score=x1_std+x2_std+x3_std+x4_std+x5_std+x6_std+x7_std+x8_std+x9_std+x10_std;
run;
data gradar4;
  set gradar3;
  keep x1_std x2_std x3_std x4_std x5_std x6_std x7_std x8_std x9_std x10_std score;
run;
data score;
  set gradar4;
  keep score;
run;


data hurst;
  set hurst1;
  if _n_=2 then delete;
run;
data hurst;
  set hurst;
  keep hurst;
run;


data stat2;
  merge stat hurst score;
run;


/*��ԭ���ĺ���ͳ�ƽ���ת��*/
proc transpose data=stat2 out=sum_stat;
  label ljjz='�ۼƾ�ֵ' yxts='��������' yfrate='�껯�޷�������' dfrate='�ջ��޷�������' yprorate='�껯������' dprorate='�ջ�������' dlcxs='�����ϵ��' 
        wwinrate='��ʤ����' max_rweek='���������������' max_dweek='��������µ�����' 
        max_drate='�������ӯ��' maxl_drate='����������' maxl_draw='��ʷ���س�' minl_drate='�������س�' recwnum='��ʷ���س��ָ�����'
        dstd='�ղ�����' ylcxs='�����ϵ��' ystd='�껯������' yddstd='�껯���б�׼��' sharp='���ձ�' sortino='����ŵ��' calmar='calmarֵ' hurst='hurstָ��' score='��Ʒ���';
run;


/*������Ҫ��ͳ������ȫ��������excel�ļ�*/
proc export data=sum_stat 
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='sumstat';
proc export data=sumdratestat
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='means';
proc export data=normalfit
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='normalfit';
proc export data=quantfit
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='quantfit';
proc export data=nobs
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='nobs';
proc export data=anova
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='anova';
proc export data=fitstat
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='fitstat';
proc export data=parest
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='parest';
run;





/*������ȡ�մ������ʡ��ۼ������ʺ����س����������excel*/
data drate;
  set pardata3(keep=date drate);
  if drate=. then drate=0;
run;
data cumdval;
  set pardata3(keep=date cumdval);
  if cumdval=. then cumdval=0;
run;
data maxdraw;
  set pardata3(keep=date maxdraw);
run;
proc export data=drate                                            /*����մ�������*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='drate';
run;
proc export data=cumdval                                            /*����ۼ�������*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='cumdval';
run;
proc export data=maxdraw                                               /*������س���*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\fund_dvalue_stat-ANALIZED.xls' 
dbms=excelcs replace;
sheet='maxdraw';
run;


                                                        /*�����״���ͼ*/
/*yprorate=x1 lcsx=x2 hurst=x3 ystd=x4 yddstd=x5 maxl_draw=x6 recwnum=x7 sharp=x8 sortino=x9 calmar=x10;*/
data gradar5;
  set gradar4;
  Profitbility=x1_std*(10/6);
  Earnstability=x2_std*(10/6);
  Earncontinuity=x3_std*(10/6);
  Earnvolatility=(x4_std*0.5+x5_std*0.5)*(10/6);
  Drawcapability=(x6_std*0.5+x7_std*0.5)*(10/6);
  ProfitRisk=(x8_std*0.4+x9_std*0.2+x10_std*0.4)*(10/6);
  RadarScores=Profitbility+Earnstability+Earncontinuity+Earnvolatility+Drawcapability+ProfitRisk;
run;


data gradar6;
  set gradar5;
  keep Profitbility Earnstability Earncontinuity Earnvolatility Drawcapability ProfitRisk;
run;
proc transpose data=gradar6 out=fundradar;run;quit;
data fundradar;
  set fundradar;
  attrib _all_ label='';
run;
data fundradar;
  set fundradar;
  rename _NAME_=subject COL1=score;
run;





/*********************************************************************************/
/*�״�ͼHTML���*/

/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\gradar--����.gif";                  /*�״�ͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output Radar=fofgradar;
proc gradar data=fundradar gout=work.fofgradar;
  chart subject/freq=score
  cstarfill=(CX7C95CA CXDE7E6F)
  starfill=(solid solid)
  cspokes=black
  ctext=black;
  title;
run;
quit;
ods output close;
ods trace off;



ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED'(url=none) body='gradar.htm';
ods graphics on;
proc gradar data=fundradar gout=work.fofgradar;
  chart subject/freq=score
  cstarfill=(CX7C95CA CXDE7E6F)
  starfill=(solid solid)
  cspokes=black
  ctext=black;
  title "gradar";
run;
quit;
ods html close;
ods listing;






data gradar7;
  set gradar5;
  keep Profitbility Earnstability Earncontinuity Earnvolatility Drawcapability ProfitRisk RadarScores;
run;
proc transpose data=gradar7 out=statgradar;run;quit;
data statgradar;
  set statgradar;
  attrib _all_ label='';
run;
data statgradar;
  set statgradar;
  rename _NAME_=Subject COL1=Score;
run;
proc export data=statgradar
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\ANALIZED\statgradar.xls'
dbms=excelcs replace;
sheet='statgradar';
run;
quit;
















/*�����վ�ֵ��ͬ��HS300��׼ָ������*/
/*********************************************************
************************************************************/
/*�����ۼƾ�ֵ���������������㣬����մ��ۼƾ�ֵ���ۼ������ʡ����س�*/
data hsdval;
  set hsdval;
    format hsdate yymmdd10.        /*�޸�ԭ���ݵ�ʱ���ʽ*/
;
    proc sort;                       /*���ݼ�����Ĭ�ϵ������������*/
    by hsdate;
run;
data hsdata1;
  set hsdval;
    hsdrate=hsdval/lag(hsdval)-1;          /*dval��ָ�մ��ۼƾ�ֵ*/
run;
	/*ȡdval�ĵ�һ��ֵ��Ϊ���ۼ������ʵķ�ĸ*/
data hsdata2;
  set hsdata1;
    retain hsfdval;
    if _N_=1 then hsfdval=hsdval;
      else hscumdval=hsdval/hsfdval-1;                /*cumdvalΪ�ۼ�������*/
run;
	  /*������ʷ���س��س�*/
data hsdata3;
  set hsdata2;
  retain hsmax_value;                                   /*retain�趨�ı�������ȥ�޸ģ����Ǳ���ǰֵ*//*retianĬ��ϵͳ��Сֵ*/
  if hsmax_value < hsdval then hsmax_value = hsdval;
  hsmaxdraw = hsdval/hsmax_value-1;
run;




/*���մ�������ȡ��������ֵ����׼��ղ����ʣ���ƫ�ȡ���ֵ*/
proc means data=hsdata3 mean std median skew kurt noprint;
  var hsdrate;
  output out=hsdratestat(keep=_stat_ hsdrate);
  title;
run;
data hsdratestat;
  set hsdratestat(rename=(_stat_=hsstat));
run;
proc sql;
create table hsdstd as select hsdrate from hsdratestat where hsstat='STD';
run;
quit;
data hsdstd;                            /*�ղ����ʣ���׼�*/
  set hsdstd(rename=(hsdrate=hsdstd));
run;





/*����ͳ��summary*/
proc sql;
create table hssummary1 as select * from hsdata3 where hsdate=(select min(hsdate) from hsdata3);
create table hssummary2 as select * from hsdata3 where hsdate=(select max(hsdate) from hsdata3);
run;
quit;
data hssummary;
  set hssummary1 hssummary2;
run;
/*���ʹ�õ�ͳ������*/
data hs_stat;
  set hssummary;
  hsljjz=((hsdval-lag(hsdval))/lag(hsdval))+1;                             /*�ۼƾ�ֵ*/
  hsyxts=hsdate-lag(hsdate);                                                   /*��������*/
  hsyfrate=0.0246;                                                                /*ָ���껯�޷���������*/
  hsdfrate=(1+hsyfrate)**(1/250)-1;                                                 /*�ջ��޷���������*/
  hsyprorate=(hsljjz**(365/hsyxts))-1;                                                  /*�껯������*/
  hsdprorate=((1+hsyprorate)**(1/250))-1;                                                    /*�ջ�������*/
  drop hsdate hsdval hsdrate hsfdval hscumdval hsmax_value hsmaxdraw;
run;
  /*��end����������һ����¼*/
data hs_stat;
  set hs_stat end=lastrec;
  if lastrec;
run;
/*�������ϵ��*/
data hs_stat;
  merge hs_stat hsdstd;                                                 /*�ղ�����*/
run;
data hs_stat;
  set hs_stat;
  hsdlcxs=abs(hsdstd/hsdprorate);                                                  /*�����ϵ��*/
  drop hsdstd;
run;




/*�����ʤ��*/
data hsweekday;
  set hsdata1;
  hsweekday=weekday(hsdate);                         /*��weekday������weekday��������ֵ����һΪ1���Դ�����*/
run;
proc sql;
create table hsweekrate as select hsdate,hsdval from hsweekday where hsweekday=6;          /*ѡ��ÿ������������Ӧ���վ�ֵ*/
run;
quit;
data hswrate;
  set hsweekrate;
  hswrate=hsdval/lag(hsdval)-1;                              /*����ܴ��վ�ֵ����*/
run;
proc sql;
create table hsweekwin1 as select count(hswrate) as hscouwwin from hswrate where hswrate>0;         /*�ҳ��ܴ�������Ϊ��������*/
run;
quit;
proc sql;
create table hsweekwin2 as select count(hswrate) as hscouweek from hswrate;                              /*�ܴ������ʵ�������*/
run;
quit;
data hsweekwin;
  merge hsweekwin1 hsweekwin2;
run;
quit;
data hsweekwin;
  set hsweekwin;
  hswwinrate=hscouwwin/hscouweek;                                  /*�ϲ��Ժ�����ܴ�ʤ����*/
run;
data hs_stat;
  set hs_stat;
  merge hs_stat hsweekwin;
  drop hscouwwin hscouweek;                                                                 /*��ʤ����*/
run;




/*�����������������������µ�����*/
/*���������ǻ����µ�����������*/
data hsmax_week;                                    /*�������ǡ��µ�����*/
  set hswrate(keep=hswrate);
  retain n 0;
  if hswrate > 0 then if n > 0 then  n=n+1;
            else n=1;
  if hswrate=0 then  n=0;
  if hswrate < 0 then if n < 0 then n=n-1;
                        else n=-1;
run;
proc means data=hsmax_week max min noprint;
  var n;
  output out=hsrdweek(drop=_TYPE_ _FREQ_ rename=(_STAT_=hs_stat));
  title;
run;
proc sql;
create table hsmax_rweek as select n as hsmax_rweek from hsrdweek where hs_stat='MAX';
create table hsmax_dweek as select n as hsmax_dweek from hsrdweek where hs_stat='MIN';
run;
quit;
data hsmax_rdweek;
  merge hsmax_rweek hsmax_dweek;
run;
data hs_stat;
  merge hs_stat hsmax_rdweek;
run;





/*���㵥�����ӯ����������*/
proc means data=hsdata1 max min noprint;
  var hsdrate;
  output out=hsmaxwl_drate(drop=_TYPE_ _FREQ_ rename=(_STAT_=hs_stat));
  title;
run;
proc sql;
create table hsmax_drate as select hsdrate as hsmax_drate from hsmaxwl_drate where hs_stat='MAX';                   /*�����ӯ��*/
create table hsmaxl_drate as select hsdrate as hsmaxl_drate from hsmaxwl_drate where hs_stat='MIN';                        /*����տ���*/
run;
quit;
data hsmax_drate;
  merge hsmax_drate hsmaxl_drate;
run;
data hs_stat;
  merge hs_stat hsmax_drate;
run;




/*��ʷ���س����������س�*/
proc means data=hsdata3 max min noprint;
  var hsmaxdraw;
output out=hsmax_draw(drop=_TYPE_ _FREQ_ rename=(_STAT_=hs_stat));
title;
run;
proc sql;
create table hsmaxl_draw as select hsmaxdraw as hsmaxl_draw from hsmax_draw where hs_stat='MIN';                                   /*��ʷ���س�*/
run;
quit;
proc means data=hsdata1 min noprint;
  var hsdrate;
  output out=hsmin_drate(drop=_TYPE_ _FREQ_ rename=(_STAT_=hs_stat));
  title;
run;
proc sql;
create table hsminl_drate as select hsdrate as hsminl_drate from hsmin_drate where hs_stat='MIN';                        /*����տ���*/
run;
quit;
data hs_stat;
  merge hs_stat hsmaxl_draw hsminl_drate;                                                                       /*�ϲ���ʷ���س����������س�*/
run;





/*��ʷ���س��ָ�ʱ��*/
data hsrec_maxdraw;
  set hsdata3(keep=hsdate hsmax_value hsmaxdraw);                      
run;
proc sql;
create table hsrec_num as select * from hsrec_maxdraw having hsmaxdraw=min(hsmaxdraw);     /*ֻ�������س�*/
run;
quit;
proc sql;
create table hsmaxdate_num as select * from hsrec_maxdraw having hsdate=max(hsdate);     /*ֻ�����������*/
run;
quit;
proc sql;
create table hszero_num as select * from hsrec_maxdraw where hsmaxdraw=0;                     /*ѡ�����лس�Ϊ0��*/
run;
quit;
data hsrecnum;
  set hsrec_num hsmaxdate_num hszero_num;
  proc sort data=hsrecnum;
  by hsdate;                                                                           /*�����ݼ������Ұ���ʱ�����򣬽����س��Ż����س�Ϊ0��ʱ����*/
run;
proc sort data=hsrecnum dupout=hsnodups3 nodupkey;
  by hsdate;
run;
data hsrecnum;
  set hsrecnum;
  n=hsdate-lag(hsdate);                                                               /*����һ��ʱ�����ڼ���һ��ʱ�����ڣ����Եõ����س��ָ����Ӹ���*/
run;
data hsrecnum;
  set hsrecnum;
  if _n_=2 then hswnum=lag(hsmaxdraw);else hswnum=lag(hsmaxdraw);                       /*��������sum�������س��˻�һ����ö�Ӧ���س�����*/
run;
proc sql;
create table hsrec_week_num as select * from hsrecnum as b having b.hswnum=min(hswnum);        /*ֻ�Ѱ������س�ֵ��һ�б�������*/
run;
quit;
data hsrecwnum(keep=hsrecwnum);
  set hsrec_week_num end=lastrec;                                                            /*��end�������ݼ������һ���۲�ֵ*/
  if lastrec then hsrecwnum=n/7;                                                                   /*�ó����س�week*/
run;
data hsrecwnum;
  set hsrecwnum end=lastrec;
  if lastrec;
run;
/*�ϲ����س��ָ�ʱ��*/
data hs_stat;
  set hs_stat;
  merge hsrecwnum;
run;




/*�ϲ��ղ����ʡ��껯������*/
data hs_stat;
  set hs_stat;
  merge hs_stat hsdstd;
  hsystd=hsdstd*sqrt(250);                    /*�껯������*/
  hsylcxs=abs(hsystd/hsyprorate);                        /*�����ϵ��*/
run;



/*�껯���б�׼��*/
data hsddex1;
  set hsdata2(keep=hsdrate);
  if hsdrate=. then delete;
run;
data hsddex2;
  set hs_stat(keep=hsdprorate);
run;
data hsddex(drop=hsdprorate);
  merge hsddex1 hsddex2;
  retain hsdpr;                                                                       /*�ջ�������*/
  if _n_=1 then hsdpr=hsdprorate;
run;
data hsddex;
  set hsddex;
  hsdiffdrate=hsdrate-hsdpr;                                                                  /*�մ�������-�ջ�������*/
run;
proc sql;
create table hsminddex as select hsdiffdrate from hsddex where hsdiffdrate < 0;
run;
quit;
data hsminddex;
  set hsminddex;
  hsexp=hsdiffdrate*hsdiffdrate;                                                                 /*�����ջ�������ƽ��*/
run;
proc sql;
create table hssumddex as select sum(hsexp) as hssumddex from hsminddex;
run;
quit;
proc sql;
create table hscountddex as select count(hsdiffdrate) as hscountddex from hsddex;
run;
quit;
data hscountddex;
  set hscountddex;
  hscountddex=hscountddex-1;                                                                          /*����sample����������Ҫn-1*/
run;
data hsddstd;
  merge hssumddex hscountddex;
  hsyddstd=sqrt(hssumddex/hscountddex)*sqrt(250);                                                               /*���б�׼��*/
run;
data hs_stat;
  set hs_stat;
  merge hs_stat hsddstd(drop=hssumddex hscountddex);
run;





/*���ձ��ʡ�sortino���ʡ�calmar����*/
data hs_stat;
  set hs_stat;
  hssharp=(hsyprorate-hsyfrate)/hsystd;       /*���ձ���*/
  hssortino=(hsyprorate-hsyfrate)/hsyddstd;     /*sortino����*/
  hscalmar=hsyprorate/abs(hsmaxl_draw);          /*calmar����*/
run;







/********************************************/
/********************************************/
/*hurst��ʼ*/


data hsdval;
  set hsdval;
  format hsdate yymmdd10.
  ;
proc sort;
by hsdate;
run;

data hsindex1;
set hsdval;
hsret=100*(log(hsdval)-log(lag(hsdval))); format hsret 8.5;
if _N_=1 then delete;
if _N_=1 then i=1;else i+1;
keep hsdate hsdval hsret i;
run;



data hsdata11;
set hsindex1;
hsj=int(i/7)+1;
run;
proc means data=hsdata11 std  mean noprint;
var hsret;
by hsj;
output out=hsdata21(drop=_type_  _freq_)
       mean=hsjunzhi
   std=hsbzc;
run;

proc sql;
create table hsdata31 as 
select 
      a.*,
  b.hsjunzhi,
  b.hsbzc

from hsdata11 a,
     hsdata21 b
where 
    a.hsj=b.hsj;
quit;

data hsdata31;
set hsdata31;
if hsret=. then delete;
run;

data hsdata41;
set hsdata31;
run;
proc sort data=hsdata41;
by descending hsdate;
run;
data hsdata41;
set hsdata31;
retain hslicha;
by hsj;
if first.hsj then hslicha=hsret-hsjunzhi; else
                hslicha=hslicha+(hsret-hsjunzhi); 

retain hsmaxlicha;
if first.hsj then hsmaxlicha=hslicha;else 
           if hsmaxlicha<hslicha then hsmaxlicha=hslicha;
retain hsmixlicha;
if first.hsj then hsmixlicha=hslicha ;else 
           if hsmixlicha>hslicha then hsmixlicha=hslicha;
if last.hsj then  hsR=(hsmaxlicha-hsmixlicha)/hsbzc; else 
          delete;
run;
data hsdata41;
  set hsdata41;
  if hsR=. then delete;
run;
data hsdata41;
  set hsdata41;
  retain hsSumR;
  if _n_=1 then hsSumR=hsR; else hsSumR=hsSumR+hsR;

  format hslicha hsmixlicha  hsmaxlicha hsR hsSumR 12.5 ;
  *drop hsdval hsret hsjunzhi hslicha    hsmixlicha  hsmaxlicha hsbzc ;
run;


data hsdata51;
set hsdata41;
hsAveR=hsSumR/hsj;
hsLogAveR=log(hsSumR/hsj);
hslogn=log(7);
n=7;
*hsstockcode="lgqq";
format hslogn hsLogAveR  hsAveR 8.5;
keep hslogn hsLogAveR n hsAveR;
run;


data hshurstdata1;
  set hsdata51;
run;


/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\fithurst--ͬ�ڻ���300.gif";                  /*hurstͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output ParameterEstimates=hsfithurst;
proc reg data=hshurstdata1 gout=work.hsfithurst;
model hsLogAveR=hslogn;
plot hsLogAveR*hslogn;
title;
run;
quit;
ods output close;
ods trace off;


/**************************************************************************************************/
/*hsfithurstͼHTML���*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='hsfithurst.htm';
proc reg data=hshurstdata1 gout=work.hsfithurst;
model hsLogAveR=hslogn;
plot hsLogAveR*hslogn;
title "hsfithurst";
run;
quit;
ods html close;
ods listing;



data hshurst1;
  set hsfithurst;
  keep variable estimate;
  attrib _all_ label="";
  rename estimate=hshurst;
run;


proc export data=hshurst1                                              /*���hurst*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\hshurst.xls' 
dbms=excelcs replace;
sheet='hshurst';
run;



data hshurst;
  set hshurst1;
  if _n_=2 then delete;
run;
data hshurst;
  set hshurst;
  keep hshurst;
run;


data hs_stat2;
  merge hs_stat hshurst;
run;



/*��ԭ���ĺ���ͳ�ƽ���ת��*/
proc transpose data=hs_stat2 out=hssum_stat;
  label hsljjz='�ۼƾ�ֵ' hsyxts='��������' hsyfrate='�껯�޷�������' hsdfrate='�ջ��޷�������' hsyprorate='�껯������' hsdprorate='�ջ�������' hsdlcxs='�����ϵ��' 
        hswwinrate='��ʤ����' hsmax_rweek='���������������' hsmax_dweek='��������µ�����' 
        hsmax_drate='�������ӯ��' hsmaxl_drate='����������' hsmaxl_draw='��ʷ���س�' hsminl_drate='�������س�' hsrecwnum='��ʷ���س��ָ�����'
        hsdstd='�ղ�����' hsylcxs='�����ϵ��' hsystd='�껯������' hsyddstd='�껯���б�׼��' hssharp='���ձ�' hssortino='����ŵ��' hscalmar='calmarֵ' hshurst='hurstָ��';
run;
                                                                    /*��log����ʾͳ�ƽ����name*/

ods trace on;
proc means data=hsdata3 mean std stderr uclm lclm n skew kurt;
  var hsdrate;
  output out=hssumdratestat;
  title;
run;
quit;
ods trace off;
data hsdrate;
  set hsdata3;
  keep hsdrate;
  if hsdrate=. then delete;
run;  

                                                                /*��������ڵ�ͳ�ƽ����ODS��������ݼ���*/
                                                    /*�ر�ͳ�������б��������*/

ods output summary=hssumdratestat;
proc means data=hsdrate mean std stderr uclm lclm n skew kurt;
  var hsdrate;
  title;
run;
quit;
ods output close;                                
                                                           /*���´�ͳ�������б��������*/

                                                                               /*��ODS��������ݼ�����ת��*/
proc transpose data=hssumdratestat out=hssumdratestat;run;




/*�����մ������ʵ������*/
data hsfitcurve(rename=(laghswrate=x hswrate=y));
  set hswrate(keep=hswrate);
  if hswrate=. then hswrate=0;
  laghswrate=lag(hswrate);
  if laghswrate=. then delete;
run;
                                                                           /*�������ͼ�ν��д��*/
/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\fitcurve-ͬ�ڻ���300.gif";         /*���ͼ����ڴ�·����*/                                                                                         
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/                                                                             
ods trace on;
ods output Nobs=hsnobs ANOVA=hsanova FitStatistics=hsfitstat ParameterEstimates=hsparest;
proc reg data=hsfitcurve gout=work.hsfitcurve;
model y=x;
plot y*x;
title;
run;
quit;
ods output close;
ods trace off;



/**************************************************************************************************/
/*fitcurveͼHTML���*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='hsfitcurve.htm';
proc reg data=hsfitcurve gout=work.hsfitcurve;
model y=x;
plot y*x;
title "hsfitcurve";
run;
quit;





                                                                                /*���ܴ������ʵĸ��ʷֲ�ͼ���д��*/
/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\hsfithistogram-ͬ�ڻ���300.gif";          /*������״ͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output TestsForNormality=hsnormalfit Quantiles=hsquantfit;
proc univariate data=hsfitcurve normal gout=work.hsfithistogram;
var x;
histogram x/normal(color=red w=2);
run;
quit;
ods output close;
ods trace off;


/**************************************************************************************************/
/*hsfithistogramͼHTML���*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='hsfithistogram.htm';
ods graphics on;
proc univariate data=hsfitcurve normal gout=work.hsfithistogram;
var x;
histogram x/normal(color=red w=2);
title 'hsfithistogram';
run;
quit;
ods html close;
ods listing;






/**************************************************************************************************/
/*hsfitpplotͼHTML���*/

                                                                                    /*���ܴ������ʵİٷ�λͼ���д��*/

/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\hsfitpplot-ͬ�ڻ���300.gif";                  /*�ٷ�λPPͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='hsfitpplot.htm';
ods graphics on;
proc univariate data=hsfitcurve normal gout=work.hsfitpplot;
var x;
probplot x/normal(mu=est sigma=est);
title "hsfitpplot";
run;
quit;
ods html close;
ods listing;






/*�˸�ʽΪ64bit��SAS��64bit��office�浼����ʽ*/
/*������Ҫ��ͳ������ȫ��������excel�ļ�*/
proc export data=hssum_stat 
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hssumstat';
proc export data=hssumdratestat
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsmeans';
proc export data=hsnormalfit
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsnormalfit';
proc export data=hsquantfit
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsquantfit';
proc export data=hsnobs
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsnobs';
proc export data=hsanova
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsanova';
proc export data=hsfitstat
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsfitstat';
proc export data=hsparest
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsparest';
run;





/*������ȡ�մ������ʡ��ۼ������ʺ����س����������excel*/
data hsdrate;
  set hsdata3(keep=hsdate hsdrate);
  if hsdrate=. then hsdrate=0;
run;
data hscumdval;
  set hsdata3(keep=hsdate hscumdval);
  if hscumdval=. then hscumdval=0;
run;
data hsmaxdraw;
  set hsdata3(keep=hsdate hsmaxdraw);
run;
proc export data=hsdrate                                            /*����մ�������*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsdrate';
run;
proc export data=hscumdval                                            /*����ۼ�������*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hscumdval';
run;
proc export data=hsmaxdraw                                               /*������س���*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-hsBENCHMARK.xls' 
dbms=excelcs replace;
sheet='hsmaxdraw';
run;












/*�����վ�ֵ��ͬ��NH0100��׼ָ������*/
/*********************************************************
************************************************************/
/*�����ۼƾ�ֵ���������������㣬����մ��ۼƾ�ֵ���ۼ������ʡ����س�*/
data nhdval;
  set nhdval;
    format nhdate yymmdd10.        /*�޸�ԭ���ݵ�ʱ���ʽ*/
;
    proc sort;                       /*���ݼ�����Ĭ�ϵ������������*/
    by nhdate;
run;
data nhdata1;
  set nhdval;
    nhdrate=nhdval/lag(nhdval)-1;          /*dval��ָ�մ��ۼƾ�ֵ*/
run;
	/*ȡdval�ĵ�һ��ֵ��Ϊ���ۼ������ʵķ�ĸ*/
data nhdata2;
  set nhdata1;
    retain nhfdval;
    if _N_=1 then nhfdval=nhdval;
      else nhcumdval=nhdval/nhfdval-1;                /*cumdvalΪ�ۼ�������*/
run;
	  /*������ʷ���س��س�*/
data nhdata3;
  set nhdata2;
  retain nhmax_value;                                   /*retain�趨�ı�������ȥ�޸ģ����Ǳ���ǰֵ*//*retianĬ��ϵͳ��Сֵ*/
  if nhmax_value < nhdval then nhmax_value = nhdval;
  nhmaxdraw = nhdval/nhmax_value-1;
run;




/*���մ�������ȡ��������ֵ����׼��ղ����ʣ���ƫ�ȡ���ֵ*/
proc means data=nhdata3 mean std median skew kurt noprint;
  var nhdrate;
  output out=nhdratestat(keep=_stat_ nhdrate);
  title;
run;
data nhdratestat;
  set nhdratestat(rename=(_stat_=nhstat));
run;
proc sql;
create table nhdstd as select nhdrate from nhdratestat where nhstat='STD';
run;
quit;
data nhdstd;                            /*�ղ����ʣ���׼�*/
  set nhdstd(rename=(nhdrate=nhdstd));
run;





/*����ͳ��summary*/
proc sql;
create table nhsummary1 as select * from nhdata3 where nhdate=(select min(nhdate) from nhdata3);
create table nhsummary2 as select * from nhdata3 where nhdate=(select max(nhdate) from nhdata3);
run;
quit;
data nhsummary;
  set nhsummary1 nhsummary2;
run;
/*���ʹ�õ�ͳ������*/
data nh_stat;
  set nhsummary;
  nhljjz=((nhdval-lag(nhdval))/lag(nhdval))+1;                             /*�ۼƾ�ֵ*/
  nhyxts=nhdate-lag(nhdate);                                                   /*��������*/
  nhyfrate=0.0246;                                                                /*ָ���껯�޷���������*/
  nhdfrate=(1+nhyfrate)**(1/250)-1;                                                 /*�ջ��޷���������*/
  nhyprorate=(nhljjz**(365/nhyxts))-1;                                                  /*�껯������*/
  nhdprorate=((1+nhyprorate)**(1/250))-1;                                                    /*�ջ�������*/
  drop nhdate nhdval nhdrate nhfdval nhcumdval nhmax_value nhmaxdraw;
run;
  /*��end����������һ����¼*/
data nh_stat;
  set nh_stat end=lastrec;
  if lastrec;
run;
/*�������ϵ��*/
data nh_stat;
  merge nh_stat nhdstd;                                                 /*�ղ�����*/
run;
data nh_stat;
  set nh_stat;
  nhdlcxs=abs(nhdstd/nhdprorate);                                                  /*�����ϵ��*/
  drop nhdstd;
run;




/*�����ʤ��*/
data nhweekday;
  set nhdata1;
  nhweekday=weekday(nhdate);                         /*��weekday������weekday��������ֵ����һΪ1���Դ�����*/
run;
proc sql;
create table nhweekrate as select nhdate,nhdval from nhweekday where nhweekday=6;          /*ѡ��ÿ������������Ӧ���վ�ֵ*/
run;
quit;
data nhwrate;
  set nhweekrate;
  nhwrate=nhdval/lag(nhdval)-1;                              /*����ܴ��վ�ֵ����*/
run;
proc sql;
create table nhweekwin1 as select count(nhwrate) as nhcouwwin from nhwrate where nhwrate>0;         /*�ҳ��ܴ�������Ϊ��������*/
run;
quit;
proc sql;
create table nhweekwin2 as select count(nhwrate) as nhcouweek from nhwrate;                              /*�ܴ������ʵ�������*/
run;
quit;
data nhweekwin;
  merge nhweekwin1 nhweekwin2;
run;
quit;
data nhweekwin;
  set nhweekwin;
  nhwwinrate=nhcouwwin/nhcouweek;                                  /*�ϲ��Ժ�����ܴ�ʤ����*/
run;
data nh_stat;
  set nh_stat;
  merge nh_stat nhweekwin;
  drop nhcouwwin nhcouweek;                                                                 /*��ʤ����*/
run;




/*�����������������������µ�����*/
/*���������ǻ����µ�����������*/
data nhmax_week;                                    /*�������ǡ��µ�����*/
  set nhwrate(keep=nhwrate);
  retain n 0;
  if nhwrate > 0 then if n > 0 then  n=n+1;
            else n=1;
  if nhwrate=0 then  n=0;
  if nhwrate < 0 then if n < 0 then n=n-1;
                        else n=-1;
run;
proc means data=nhmax_week max min noprint;
  var n;
  output out=nhrdweek(drop=_TYPE_ _FREQ_ rename=(_STAT_=nh_stat));
  title;
run;
proc sql;
create table nhmax_rweek as select n as nhmax_rweek from nhrdweek where nh_stat='MAX';
create table nhmax_dweek as select n as nhmax_dweek from nhrdweek where nh_stat='MIN';
run;
quit;
data nhmax_rdweek;
  merge nhmax_rweek nhmax_dweek;
run;
data nh_stat;
  merge nh_stat nhmax_rdweek;
run;





/*���㵥�����ӯ����������*/
proc means data=nhdata1 max min noprint;
  var nhdrate;
  output out=nhmaxwl_drate(drop=_TYPE_ _FREQ_ rename=(_STAT_=nh_stat));
  title;
run;
proc sql;
create table nhmax_drate as select nhdrate as nhmax_drate from nhmaxwl_drate where nh_stat='MAX';                   /*�����ӯ��*/
create table nhmaxl_drate as select nhdrate as nhmaxl_drate from nhmaxwl_drate where nh_stat='MIN';                        /*����տ���*/
run;
quit;
data nhmax_drate;
  merge nhmax_drate nhmaxl_drate;
run;
data nh_stat;
  merge nh_stat nhmax_drate;
run;




/*��ʷ���س����������س�*/
proc means data=nhdata3 max min noprint;
  var nhmaxdraw;
output out=nhmax_draw(drop=_TYPE_ _FREQ_ rename=(_STAT_=nh_stat));
title;
run;
proc sql;
create table nhmaxl_draw as select nhmaxdraw as nhmaxl_draw from nhmax_draw where nh_stat='MIN';                                   /*��ʷ���س�*/
run;
quit;
proc means data=nhdata1 min noprint;
  var nhdrate;
  output out=nhmin_drate(drop=_TYPE_ _FREQ_ rename=(_STAT_=nh_stat));
  title;
run;
proc sql;
create table nhminl_drate as select nhdrate as nhminl_drate from nhmin_drate where nh_stat='MIN';                        /*����տ���*/
run;
quit;
data nh_stat;
  merge nh_stat nhmaxl_draw nhminl_drate;                                                                       /*�ϲ���ʷ���س����������س�*/
run;





/*��ʷ���س��ָ�ʱ��*/
data nhrec_maxdraw;
  set nhdata3(keep=nhdate nhmax_value nhmaxdraw);                      
run;
proc sql;
create table nhrec_num as select * from nhrec_maxdraw having nhmaxdraw=min(nhmaxdraw);     /*ֻ�������س�*/
run;
quit;
proc sql;
create table nhmaxdate_num as select * from nhrec_maxdraw having nhdate=max(nhdate);     /*ֻ�����������*/
run;
quit;
proc sql;
create table nhzero_num as select * from nhrec_maxdraw where nhmaxdraw=0;                     /*ѡ�����лس�Ϊ0��*/
run;
quit;
data nhrecnum;
  set nhrec_num nhmaxdate_num nhzero_num;
  proc sort data=nhrecnum;
  by nhdate;                                                                           /*�����ݼ������Ұ���ʱ�����򣬽����س��Ż����س�Ϊ0��ʱ����*/
run;
proc sort data=nhrecnum dupout=nhnodups3 nodupkey;
  by nhdate;
run;
data nhrecnum;
  set nhrecnum;
  n=nhdate-lag(nhdate);                                                               /*����һ��ʱ�����ڼ���һ��ʱ�����ڣ����Եõ����س��ָ����Ӹ���*/
run;
data nhrecnum;
  set nhrecnum;
  if _n_=2 then nhwnum=lag(nhmaxdraw);else nhwnum=lag(nhmaxdraw);                       /*��������sum�������س��˻�һ����ö�Ӧ���س�����*/
run;
proc sql;
create table nhrec_week_num as select * from nhrecnum as b having b.nhwnum=min(nhwnum);        /*ֻ�Ѱ������س�ֵ��һ�б�������*/
run;
quit;
data nhrecwnum(keep=nhrecwnum);
  set nhrec_week_num end=lastrec;                                                            /*��end�������ݼ������һ���۲�ֵ*/
  if lastrec then nhrecwnum=n/7;                                                                   /*�ó����س�week*/
run;
data nhrecwnum;
  set nhrecwnum end=lastrec;
  if lastrec;
run;
/*�ϲ����س��ָ�ʱ��*/
data nh_stat;
  set nh_stat;
  merge nhrecwnum;
run;




/*�ϲ��ղ����ʡ��껯������*/
data nh_stat;
  set nh_stat;
  merge nh_stat nhdstd;
  nhystd=nhdstd*sqrt(250);                    /*�껯������*/
  nhylcxs=abs(nhystd/nhyprorate);                        /*�����ϵ��*/
run;



/*�껯���б�׼��*/
data nhddex1;
  set nhdata2(keep=nhdrate);
  if nhdrate=. then delete;
run;
data nhddex2;
  set nh_stat(keep=nhdprorate);
run;
data nhddex(drop=nhdprorate);
  merge nhddex1 nhddex2;
  retain nhdpr;                                                                       /*�ջ�������*/
  if _n_=1 then nhdpr=nhdprorate;
run;
data nhddex;
  set nhddex;
  nhdiffdrate=nhdrate-nhdpr;                                                                  /*�մ�������-�ջ�������*/
run;
proc sql;
create table nhminddex as select nhdiffdrate from nhddex where nhdiffdrate < 0;
run;
quit;
data nhminddex;
  set nhminddex;
  nhexp=nhdiffdrate*nhdiffdrate;                                                                 /*�����ջ�������ƽ��*/
run;
proc sql;
create table nhsumddex as select sum(nhexp) as nhsumddex from nhminddex;
run;
quit;
proc sql;
create table nhcountddex as select count(nhdiffdrate) as nhcountddex from nhddex;
run;
quit;
data nhcountddex;
  set nhcountddex;
  nhcountddex=nhcountddex-1;                                                                          /*����sample����������Ҫn-1*/
run;
data nhddstd;
  merge nhsumddex nhcountddex;
  nhyddstd=sqrt(nhsumddex/nhcountddex)*sqrt(250);                                                               /*���б�׼��*/
run;
data nh_stat;
  set nh_stat;
  merge nh_stat nhddstd(drop=nhsumddex nhcountddex);
run;





/*���ձ��ʡ�sortino���ʡ�calmar����*/
data nh_stat;
  set nh_stat;
  nhsharp=(nhyprorate-nhyfrate)/nhystd;       /*���ձ���*/
  nhsortino=(nhyprorate-nhyfrate)/nhyddstd;     /*sortino����*/
  nhcalmar=nhyprorate/abs(nhmaxl_draw);          /*calmar����*/
run;







/********************************************/
/********************************************/
/*hurst��ʼ*/


data nhdval;
  set nhdval;
  format nhdate yymmdd10.
  ;
proc sort;
by nhdate;
run;

data nhindex1;
set nhdval;
nhret=100*(log(nhdval)-log(lag(nhdval))); format nhret 8.5;
if _N_=1 then delete;
if _N_=1 then i=1;else i+1;
keep nhdate nhdval nhret i;
run;



data nhdata11;
set nhindex1;
nhj=int(i/7)+1;
run;
proc means data=nhdata11 std  mean noprint;
var nhret;
by nhj;
output out=nhdata21(drop=_type_  _freq_)
       mean=nhjunzhi
   std=nhbzc;
run;

proc sql;
create table nhdata31 as 
select 
      a.*,
  b.nhjunzhi,
  b.nhbzc

from nhdata11 a,
     nhdata21 b
where 
    a.nhj=b.nhj;
quit;

data nhdata31;
set nhdata31;
if nhret=. then delete;
run;

data nhdata41;
set nhdata31;
run;
proc sort data=nhdata41;
by descending nhdate;
run;
data nhdata41;
set nhdata31;
retain nhlicha;
by nhj;
if first.nhj then nhlicha=nhret-nhjunzhi; else
                nhlicha=nhlicha+(nhret-nhjunzhi); 

retain nhmaxlicha;
if first.nhj then nhmaxlicha=nhlicha;else 
           if nhmaxlicha<nhlicha then nhmaxlicha=nhlicha;
retain nhmixlicha;
if first.nhj then nhmixlicha=nhlicha ;else 
           if nhmixlicha>nhlicha then nhmixlicha=nhlicha;
if last.nhj then  nhR=(nhmaxlicha-nhmixlicha)/nhbzc; else 
          delete;
run;
data nhdata41;
  set nhdata41;
  if nhR=. then delete;
run;
data nhdata41;
  set nhdata41;
  retain nhSumR;
  if _n_=1 then nhSumR=nhR; else nhSumR=nhSumR+nhR;

  format nhlicha nhmixlicha  nhmaxlicha nhR nhSumR 12.5 ;
  *drop nhdval nhret nhjunzhi nhlicha    nhmixlicha  nhmaxlicha nhbzc ;
run;


data nhdata51;
set nhdata41;
nhAveR=nhSumR/hsj;
nhLogAveR=log(nhSumR/nhj);
nhlogn=log(7);
n=7;
*nhstockcode="lgqq";
format nhlogn nhLogAveR  nhAveR 8.5;
keep nhlogn nhLogAveR n nhAveR;
run;


data nhhurstdata1;
  set nhdata51;
run;


/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\fithurst--ͬ�ڻ���300.gif";                  /*hurstͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output ParameterEstimates=nhfithurst;
proc reg data=nhhurstdata1 gout=work.nhfithurst;
model nhLogAveR=nhlogn;
plot nhLogAveR*nhlogn;
title;
run;
quit;
ods output close;
ods trace off;


/**************************************************************************************************/
/*nhfithurstͼHTML���*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='nhfithurst.htm';
proc reg data=nhhurstdata1 gout=work.nhfithurst;
model nhLogAveR=nhlogn;
plot nhLogAveR*nhlogn;
title "nhfithurst";
run;
quit;
ods html close;
ods listing;



data nhhurst1;
  set nhfithurst;
  keep variable estimate;
  attrib _all_ label="";
  rename estimate=nhhurst;
run;


proc export data=nhhurst1                                              /*���hurst*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\nhhurst.xls' 
dbms=excelcs replace;
sheet='nhhurst';
run;



data nhhurst;
  set nhhurst1;
  if _n_=2 then delete;
run;
data nhhurst;
  set nhhurst;
  keep nhhurst;
run;


data nh_stat2;
  merge nh_stat nhhurst;
run;



/*��ԭ���ĺ���ͳ�ƽ���ת��*/
proc transpose data=nh_stat2 out=nhsum_stat;
  label nhljjz='�ۼƾ�ֵ' nhyxts='��������' nhyfrate='�껯�޷�������' nhdfrate='�ջ��޷�������' nhyprorate='�껯������' nhdprorate='�ջ�������' nhdlcxs='�����ϵ��' 
        nhwwinrate='��ʤ����' nhmax_rweek='���������������' nhmax_dweek='��������µ�����' 
        nhmax_drate='�������ӯ��' nhmaxl_drate='����������' nhmaxl_draw='��ʷ���س�' nhminl_drate='�������س�' nhrecwnum='��ʷ���س��ָ�����'
        nhdstd='�ղ�����' nhylcxs='�����ϵ��' nhystd='�껯������' nhyddstd='�껯���б�׼��' nhsharp='���ձ�' nhsortino='����ŵ��' nhcalmar='calmarֵ' nhhurst='hurstָ��';
run;
                                                                    /*��log����ʾͳ�ƽ����name*/

ods trace on;
proc means data=nhdata3 mean std stderr uclm lclm n skew kurt;
  var nhdrate;
  output out=nhsumdratestat;
  title;
run;
quit;
ods trace off;
data nhdrate;
  set nhdata3;
  keep nhdrate;
  if nhdrate=. then delete;
run;  

                                                                /*��������ڵ�ͳ�ƽ����ODS��������ݼ���*/
                                                    /*�ر�ͳ�������б��������*/

ods output summary=nhsumdratestat;
proc means data=nhdrate mean std stderr uclm lclm n skew kurt;
  var nhdrate;
  title;
run;
quit;
ods output close;                                
                                                           /*���´�ͳ�������б��������*/

                                                                               /*��ODS��������ݼ�����ת��*/
proc transpose data=nhsumdratestat out=nhsumdratestat;run;




/*�����մ������ʵ������*/
data nhfitcurve(rename=(lagnhwrate=x nhwrate=y));
  set nhwrate(keep=nhwrate);
  if nhwrate=. then nhwrate=0;
  lagnhwrate=lag(nhwrate);
  if lagnhwrate=. then delete;
run;
                                                                           /*�������ͼ�ν��д��*/
/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\fitcurve-ͬ�ڻ���300.gif";         /*���ͼ����ڴ�·����*/                                                                                         
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/                                                                             
ods trace on;
ods output Nobs=nhnobs ANOVA=nhanova FitStatistics=nhfitstat ParameterEstimates=nhparest;
proc reg data=nhfitcurve gout=work.nhfitcurve;
model y=x;
plot y*x;
title;
run;
quit;
ods output close;
ods trace off;



/**************************************************************************************************/
/*fitcurveͼHTML���*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='nhfitcurve.htm';
proc reg data=nhfitcurve gout=work.nhfitcurve;
model y=x;
plot y*x;
title "nhfitcurve";
run;
quit;





                                                                                /*���ܴ������ʵĸ��ʷֲ�ͼ���д��*/
/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\hsfithistogram-ͬ�ڻ���300.gif";          /*������״ͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods trace on;
ods output TestsForNormality=nhnormalfit Quantiles=nhquantfit;
proc univariate data=nhfitcurve normal gout=work.nhfithistogram;
var x;
histogram x/normal(color=red w=2);
run;
quit;
ods output close;
ods trace off;


/**************************************************************************************************/
/*hsfithistogramͼHTML���*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='nhfithistogram.htm';
ods graphics on;
proc univariate data=nhfitcurve normal gout=work.nhfithistogram;
var x;
histogram x/normal(color=red w=2);
title 'nhfithistogram';
run;
quit;
ods html close;
ods listing;






/**************************************************************************************************/
/*hsfitpplotͼHTML���*/

                                                                                    /*���ܴ������ʵİٷ�λͼ���д��*/

/*filename gifout "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\����\ͬ�ڻ���300\hsfitpplot-ͬ�ڻ���300.gif";                  /*�ٷ�λPPͼ����ڴ�·����*/
/*goptions reset=all device=gif gsfname=gifout gsfmode=replace;*/
ods listing close;
ods html path='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK'(url=none) body='nhfitpplot.htm';
ods graphics on;
proc univariate data=nhfitcurve normal gout=work.nhfitpplot;
var x;
probplot x/normal(mu=est sigma=est);
title "nhfitpplot";
run;
quit;
ods html close;
ods listing;






/*�˸�ʽΪ64bit��SAS��64bit��office�浼����ʽ*/
/*������Ҫ��ͳ������ȫ��������excel�ļ�*/
proc export data=hssum_stat 
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhsumstat';
proc export data=hssumdratestat
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhmeans';
proc export data=hsnormalfit
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhnormalfit';
proc export data=hsquantfit
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhquantfit';
proc export data=hsnobs
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhnobs';
proc export data=hsanova
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhanova';
proc export data=hsfitstat
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhfitstat';
proc export data=hsparest
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhparest';
run;





/*������ȡ�մ������ʡ��ۼ������ʺ����س����������excel*/
data nhdrate;
  set nhdata3(keep=nhdate nhdrate);
  if nhdrate=. then nhdrate=0;
run;
data nhcumdval;
  set nhdata3(keep=nhdate nhcumdval);
  if nhcumdval=. then nhcumdval=0;
run;
data nhmaxdraw;
  set nhdata3(keep=nhdate nhmaxdraw);
run;
proc export data=nhdrate                                            /*����մ�������*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhdrate';
run;
proc export data=nhcumdval                                            /*����ۼ�������*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhcumdval';
run;
proc export data=nhmaxdraw                                               /*������س���*/
outfile='D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\BENCHMARK\fund_dvalue_stat-nhBENCHMARK.xls' 
dbms=excelcs replace;
sheet='nhmaxdraw';
run;







/*****************************************************************/
/*�Ѳ������ݼ�sum_stat�ͻ�׼���ݼ�hssum_stat������Խ��߼���mylib��*/
/****************************************************************/

libname mylib "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\MYLIB";
data mylib.sum_stat;
set sum_stat;
run;


libname mylib "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\MYLIB";
data mylib.hssum_stat;
set hssum_stat;
run;


libname mylib "D:\AstroInvest Files\03_��Ӫ��Ʒ\���������\ANALIZED_DATA\MYLIB";
data mylib.nhsum_stat;
set nhsum_stat;
run;
