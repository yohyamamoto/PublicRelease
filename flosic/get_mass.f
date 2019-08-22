C UTEP Electronic Structure Lab (2019)
C
       SUBROUTINE GET_MASS(NUMBER,MASS)
C
C      RETURNS THE ATOMIC MASS OF THE SUPPLIED ATOMIC NUMBER.
C
C      BY ULISES REVELES, JUNE 2013.
C
C      -----------------------------------------------------------------
C      
       INTEGER NUMBER
       REAL*8 MASS
C
C      -----------------------------------------------------------------
C
       DIMENSION ATMASS(0:56)
       DATA ATMASS/0.0, 1.00797, 4.0026, 6.939, 9.0122, 10.811, 12.01115
     &            , 14.0067, 15.9994, 18.9984, 20.179, 22.9898, 24.305
     &            , 26.9815, 28.086, 30.9738, 32.064, 35.453, 39.948
     &            , 39.102, 40.08, 44.956, 47.90, 50.942, 51.996
     &            , 54.9381, 55.847, 58.9332, 58.71, 63.546, 65.37
     &            , 69.72, 72.59, 74.9216, 78.96, 79.904, 83.80, 85.47
     &            , 87.62, 88.905, 91.22, 92.906, 95.94, 98.906, 101.07
     &            , 102.905, 106.4, 107.868, 112.40, 114.82, 118.69
     &            , 121.75, 127.60, 126.9044, 131.30, 132.905, 137.34/
       MASS=ATMASS(NUMBER)
C
C      -----------------------------------------------------------------
C
       END SUBROUTINE GET_MASS
