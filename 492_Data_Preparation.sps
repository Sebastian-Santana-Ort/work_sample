* Encoding: UTF-8.
* This file contains all computations for preparing the 492 SA dataset

* COMPUTE TIME VARIABLE.

* Used to calculate date differences.
COMPUTE time_raw = datediff(Date,Baseline,'days').
EXECUTE.
* I then devided raw number of days by 30 to get number of months with decimals.
COMPUTE time=time_raw/30.
EXECUTE.


* COMPUTE ZARIT SCORE.
COMPUTE Zarit_sum = sum.1(CD1, CD2, CD3, CD4, CD5, CD6, CD7, CD8, CD9, CD10, CD11, CD12).
exe.
*Suggested guidelines for scoring:
? 0-10: no to mild burden
? 10-20: mild to moderate burden
? >20: high burden.
IF (Zarit_sum LT 11) Zarit_CGB = 0.
IF (Zarit_sum > 10) AND (Zarit_sum < 21) Zarit_CGB = 1.
IF (Zarit_sum > 20) Zarit_CGB = 2.
EXECUTE.
VALUE LABELS Zarit_CGB "0" no to mild burden "1" mild to moderate burden "2" high burden.


* COMPUTE SOCIAL ACTIVITY SCORE.
* Reverse code item.
RECODE SA2 (2 =0) (1=1) (0=2).

*This compues a sum total of the six SA questions, with a minimum of three responded.
COMPUTE SA_Total = SUM.3(SA1, SA2, SA3, SA4, SA5, SA6).

*COMPUTE RELIABILITY SCORE

* RELIABILITY FOR SOCIAL ACTIVITIES.

  RELIABILITY
  /VARIABLES= SA1 SA2 SA3 SA5 SA6
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

CORRELATIONS 
  /VARIABLES=SA1 SA2 SA3 SA4 SA5 SA6 
  /PRINT=TWOTAIL NOSIG 
  /STATISTICS XPROD 
  /MISSING=PAIRWISE.

* Oblique rotation.
FACTOR
 /VARIABLES SA1 SA2 SA3 SA4 SA5 SA6
 /FORMAT SORT BLANK(.35)
  /EXTRACTION PAF
/ROTATION OBLIMIN.
* Orthogonal rotation.
FACTOR
  /VARIABLES SA1 SA2 SA3 SA4 SA5 SA6
  /MISSING LISTWISE 
  /ANALYSIS SA1 SA2 SA3 SA4 SA5 SA6
  /PRINT INITIAL EXTRACTION ROTATION FSCORE
  /FORMAT SORT BLANK(.32)
  /PLOT ROTATION
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.


*RELIABILITY FOR ZARIT.
  RELIABILITY
  /VARIABLES= CD1, CD2, CD3, CD4, CD5, CD6, CD7, CD8, CD9, CD10, CD11, CD12
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

CORRELATIONS 
  /VARIABLES=CD1, CD2, CD3, CD4, CD5, CD6, CD7, CD8, CD9, CD10, CD11, CD12
  /PRINT=TWOTAIL NOSIG 
  /STATISTICS XPROD 
  /MISSING=PAIRWISE.

