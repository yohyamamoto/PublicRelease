C UTEP Electronic Structure Lab (2019)
C
       SUBROUTINE FERMILVOCC
     &  (NVIRT,ELECTRONS,EFRM,TEMP,EVAL,OCCUPANCY,NDEG)
       IMPLICIT REAL*8 (A-H,O-Z)
       DIMENSION EVAL(*),OCCUPANCY(*),NDEG(*)
       LOGICAL LITER,EXIST
       DATA TOL/1.0D-10/
           EXIST=.FALSE.
           INQUIRE(FILE='FRMIDT',EXIST=EXIST)
           IF(EXIST)THEN
              DO I=1,NVIRT
              OCCUPANCY(I)=-1.0D0
              END DO
              FOUND=0.0D0
 42           CONTINUE
              K=0
              EMIN=1.0D30
              DO I=1,NVIRT
C               IF(NDEG(I).GT.2.OR.NDEG(I).LE.0)THEN
C                 PRINT*,'NOT YET SYMMETRIZED'
C                 PRINT*,'STOPPING IN FERMILV'
C                 CALL STOPIT
C                END IF
                IF(OCCUPANCY(I).LT.0.0D0.AND.EVAL(I).LT.EMIN)THEN
                  K=I
                  EMIN=EVAL(I)
                END IF
              END DO
              OCC=MIN((ELECTRONS-FOUND)/NDEG(K),1.0D0) 
              OCCUPANCY(K)=OCC   
              FOUND=FOUND+OCCUPANCY(K)*NDEG(K)
              PRINT 43,I,K,EVAL(K),OCCUPANCY(K),ELECTRONS,FOUND
 43           FORMAT(2I5,4F12.6)
              IF(FOUND.GT.ELECTRONS)CALL STOPIT
              IF(ABS(ELECTRONS-FOUND).GT.0.1)GO TO 42
              DO I=1,NVIRT
              IF(OCCUPANCY(I).LT.0.0D0)OCCUPANCY(I)=0.0D0
              END DO
           RETURN
           END IF
C
C SOME TESTS
C
       IF (NVIRT.LE.0) THEN
        PRINT *,'FERMILV: NO LEVELS FOUND'
        EFRM=0.0D0
        RETURN
       END IF
C
C GET EXTREMAL EIGENVALUES AND NUMBER OF STATES
C CHECK IF NUMBER OF ELECTRONS IS WITHIN LIMITS
C
       ELECMAX=0.0D0
       EMIN=  1.0D30
       EMAX= -1.0D30
       DO IVIRT=1,NVIRT
        OCCUPANCY(IVIRT)=0.0D0
        ELECMAX=ELECMAX+NDEG(IVIRT)
        IF (EVAL(IVIRT).LT.EMIN) EMIN=EVAL(IVIRT)
        IF (EVAL(IVIRT).GT.EMAX) EMAX=EVAL(IVIRT)
       END DO
       IF (ELECTRONS .LE. TOL) THEN
        PRINT *,'FERMILV: NO ELECTRONS FOUND'
        CHARGE=ELECTRONS
        IF (TEMP.GE.0.0D0) THEN
         EFRM=EMIN-20*TEMP
        ELSE
         EFRM=EMAX-20*TEMP
        END IF
        GOTO 100
       END IF
       IF (ELECTRONS.GT.ELECMAX) THEN
        PRINT *,'FERMILV: TOO MANY ELECTRONS'
        CALL STOPIT
       END IF
C
C FIRST: ASSUME TEMP=0
C DEFINE OCCUPANCIES
C
       DO IVIRT=1,NVIRT
        OCCUPANCY(IVIRT)= -1.0D0
       END DO
       CHARGE=0.0D0
       DO 10 IVIRT=1,NVIRT
        EFRM=1.0D30
        KFRM=0
        DO JVIRT=1,NVIRT
         IF (OCCUPANCY(JVIRT) .LT. -0.1D0) THEN
          IF (EVAL(JVIRT) .LT. EFRM) THEN
           KFRM=JVIRT
           EFRM=EVAL(JVIRT)
          END IF
         END IF
        END DO
        IF (ELECTRONS-CHARGE .GT. NDEG(KFRM)) THEN
         OCCUPANCY(KFRM)=1.0D0
         KHOMO=KFRM
        ELSE
         OCCUPANCY(KFRM)=(ELECTRONS-CHARGE)/NDEG(KFRM)
         IF (OCCUPANCY(KFRM) .LT. 0.0D0) OCCUPANCY(KFRM)=0.0D0
         IF (OCCUPANCY(KFRM) .GT. TOL) KHOMO=KFRM
        END IF
        CHARGE=CHARGE+NDEG(KFRM)*OCCUPANCY(KFRM)
   10  CONTINUE
C
C FIND DISTANCE TO CLOSEST STATES
C
       DEUP=1.0D30
       DEDN=1.0D30
       DO IVIRT=1,NVIRT
        IF (IVIRT.NE.KHOMO) THEN
         EDIFF=EVAL(IVIRT)-EVAL(KHOMO)
         IF (EDIFF .GE. 0.0D0) THEN
          DEUP=MIN(DEUP,+EDIFF)
         ELSE
          DEDN=MIN(DEDN,-EDIFF)
         END IF
        END IF
       END DO
C
C DEFINE EFERMI BASED ON T=0
C
       IF (OCCUPANCY(KHOMO)+TOL .LT. 1.0D0) THEN
        EFRM=EVAL(KHOMO)
       ELSE
        EFRM=EVAL(KHOMO)+0.5D0*DEUP
       END IF
C
C DECIDE IF ITERATION IS NECESSARY
C
       ETOL=ABS(LOG(TOL)*TEMP)
       LITER=.FALSE.
       IF (OCCUPANCY(KHOMO)+TOL .LT. 1.0D0) THEN
        IF (MIN(DEUP,DEDN) .LT. ETOL) LITER=.TRUE.
       ELSE
        IF (DEUP .LT. ETOL) LITER=.TRUE.
       END IF
       IF (.NOT.LITER) GOTO 100
C
C WE NEED ITERATION
C
       IF (TEMP.LT.TOL) THEN
        PRINT *,'FERMILV: TEMPERATURE IS TOO SMALL'
        CALL STOPIT
       END IF
       TEMPRC=1.0D0/TEMP
C
       ETOL=10*ABS(LOG(TOL)*TEMP)
       EMIN=EMIN-ETOL
       EMAX=EMAX+ETOL
       EFOLD=EMAX
       OPEN(47,FILE='FRMLV',FORM='FORMATTED',STATUS='UNKNOWN')
       REWIND(47)
       WRITE(47,*)'EMIN,EMAX:',EMIN,EMAX
       WRITE(47,*)'TEMPERATURE:',TEMP
C
C DO BISECTION TO FIND EFERMI
C
   20  CONTINUE
        EFRM=0.5D0*(EMAX+EMIN)
        CHARGE=0.0D0
        DO 30 IVIRT=1,NVIRT
         DELTA=(EVAL(IVIRT)-EFRM)*TEMPRC
         IF (DELTA .GT. 40.0D0) THEN
          OCCUPANCY(IVIRT)=EXP(-DELTA)
         ELSE
          OCCUPANCY(IVIRT)=1.0D0/(1.0D0+EXP(DELTA))
         END IF
         CHARGE=CHARGE+OCCUPANCY(IVIRT)*NDEG(IVIRT)
   30   CONTINUE
        WRITE(47,1020) EMIN,EFRM,EMAX,CHARGE
        IF (ABS(CHARGE-ELECTRONS).LT.TOL) THEN
         IF (ABS(EFOLD-EFRM).LT.TOL) GOTO 50
        END IF
        EFOLD=EFRM
        IF (CHARGE.GT.ELECTRONS) THEN
         EMAX=EFRM
        ELSE
         EMIN=EFRM
        END IF
       GOTO 20
   50  CONTINUE
       CLOSE(47)
  100  CONTINUE
 1020  FORMAT(' MIN,FERMI,MAX,CHARGE:',4(1X,G14.6))
       RETURN
       END
