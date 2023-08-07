* Encoding: UTF-8.
RECODE QOL1 QOL2 QOL3 QOL4 QOL5 QOL6 QOL7 QOL8 QOL9 QOL10 
QOL11 QOL12 QOL13 QOL14 QOL15 QOL16
QOL17 QOL18 QOL19 QOL20 QOL21 QOL22 
QOL23 QOL24 QOL25 QOL26
(1=1) (2=2) (3=3) (4=4) (5=5) (ELSE=SYSMIS). 

*(This recodes all data outside the range 1-5 to system missing.) 

RECODE QOL3.1 QOL4.1 QOL26.1 (1=5) (2=4) (3=3) (4=2) (5=1). 
*(This transforms negatively framed questions to positively framed questions.) 

COMPUTE PHYS=MEAN.6(QOL3,QOL4,QOL10,QOL15,QOL16,QOL17,QOL18)*4.
COMPUTE PSYCH=MEAN.5(QOL5,QOL6,QOL7,QOL11,QOL19,QOL26)*4.
COMPUTE SOCIAL=MEAN.2(QOL20,QOL21,QOL22)*4.
COMPUTE ENVIR=MEAN.6(QOL8,QOL9,QOL12,QOL13,QOL14,QOL23,QOL24,QOL25)*4.

*(These equations calculate the domain scores. All scores are multiplied by 4 so as
to be directly comparable with scores derived from the WHOQOL-100. The ‘.6’
in ‘mean.6’ specifies that 6 items must be endorsed for the domain score to be
calculated.) 

COMPUTE PHYS=(PHYS-4)*(100/16).
COMPUTE PSYCH=(PSYCH-4)*(100/16).
COMPUTE SOCIAL=(SOCIAL-4)*(100/16).
COMPUTE ENVIR=(ENVIR-4)*(100/16).

* Transform scores to a 0-100 scale 

COUNT TOTAL=QOL1 TO QOL26 (1 THRU 5).

*(This command creates a new column ‘total’. ‘Total’ contains a count of the
WHOQOL-BREF items with the values 1-5 that have been endorsed by each
subject. The ‘Q1 TO Q26’ means that consecutive columns from ‘Q1’, the first
item, to ‘Q26’, the last item, are included in the count. It therefore assumes that
data is entered in the order given in the assessment.)

SELECT IF (TOTAL>=21).
EXECUTE.

*(This second command selects only those cases where ‘total’, the total number of
items completed, is greater than or equal to 80%. It deletes the remaining cases
from the dataset.) 
