C UTEP Electronic Structure Lab (2019)
C
C> @file loravel.f
C> This is actually the old LORAVEL
       SUBROUTINE LORAVEL(IFNCT,ISHELLA,I_SITE,RVEC,RVECI,N_NUC,ILOC)
C> ORIGINALLY WRITTEN BY MARK R PEDERSON (1985)
C> UPDATED FOR SIC FALL 2013
       use common2, only : LSYMMAX,N_CON, ISPN, NSPN
       use common5, only : PSI_COEF, OCCUPANCY, N_OCC, PSI, NWF,
     &                     NWFS,EVLOCC
       use common8, only : REP, N_REP, NDMREP, U_MAT, N_SALC, INDBEG
!SIC module
       use LOCORB,only : TMAT,MORB,ZSIC,IRBSIC
       use MOCORB,only : SLAT,NFRM,ZTZL,JJJJJJ
       use ORBENG,only : EVALOCC
! Conversion to implicit none.  Raja Zope Thu Aug 17 14:34:52 MDT 2017

!      INCLUDE  'PARAMAS'  
       INCLUDE  'PARAMA2'  
       INTEGER :: IFNCT, ISHELLA, I_SITE, N_NUC, ILOC, I_LOCAL, I_SALC,
     & IBASE, ICALL1, ICALL2, IDUMMY, IMS, IND_SALC, INDEX, IOCC, IORB,
     & IQ, IQ_BEG, IROW, ISHELL, ISHELLV, ITOT, IWF, J_LOCAL, JORB,
     & JSPN, JWF, K_REP, K_ROW, KSALC, LI, MLOCAL, MU, NDEG
       REAL*8 :: RVEC , RVECI, FACTOR, PHILOC
!       COMMON/LOCORB/TMAT(MAX_OCC,MAX_OCC,MXSPN),MORB(2),ZSIC,IRBSIC
!       COMMON/MOCORB/SLAT(MAX_OCC,MAX_OCC,MXSPN),NFRM(2),ZTZL,JJJJJJ
!       INCLUDE 'commons.inc'
C       COMMON/MOCORB/SLAT(MAX_OCC,MAX_OCC,MXSPN),NFRM(2),JJJJJJ,ZTZL
C       COMMON/LOCORB/TMAT(MAX_OCC,MAX_OCC,MXSPN),MORB(2),IRBSIC,ZSIC
!       COMMON/ORBENG/EVALOCC(MAX_OCC)
       save
       DIMENSION NDEG(3),IND_SALC(ISMAX,MAX_CON,3)
       DIMENSION RVECI(3,MX_GRP),RVEC(3)
       DIMENSION ISHELLV(2)
       DIMENSION PHILOC(MAX_OCC)
       DATA IDUMMY/0/
       DATA NDEG/1,3,6/
       DATA ICALL1,ICALL2,ISHELL/0,0,0/
C             PRINT*,'NPIN:',NSPN
              DO JSPN=1,NSPN
C             PRINT*,'SPIN:',ISPN
C THa fix:  changed MORB(ISPN) -> MORB(JSPN) because ISPN may be 3 here
               MORB(JSPN)=NFRM(JSPN)
                 DO IWF=1,NWFS(JSPN)
                   DO IORB=1,NFRM(JSPN)
                     TMAT(IORB,IWF,JSPN)=SLAT(IORB,IWF,JSPN)
                  END DO
C       PRINT*,(TMAT(IWF,IORB,ISPN),IORB=1,KORB(JSPN))
C       PRINT*,(SLAT(IWF,IORB,ISPN),IORB=1,KORB(JSPN))
                 END DO
              END DO  ! END DO JSPN=1,NSPN
C      READ*,DUMMY
       IF(I_SITE.EQ.1)THEN
        ICALL1=ICALL1+1
        CALL OBINFO(1,RVEC,RVECI,N_NUC,ISHELLV(ILOC))
        CALL GSMAT(ISHELLV(ILOC),ILOC)
       END IF
       ISHELL=ISHELLV(ILOC)
C
C UNSYMMETRIZE THE WAVEFUNCTIONS....
C
       ITOT=0
       IWF=0
       DO 1020 ISPN=1,NSPN
        KSALC=0
        DO 1010 K_REP=1,N_REP
C
C CALCULATE ARRAY LOCATIONS:
C
         DO 5 K_ROW=1,NDMREP(K_REP)
          KSALC=KSALC+1
    5    CONTINUE
         INDEX=INDBEG(ISHELLA,K_REP)
         DO 20 LI =0,LSYMMAX(IFNCT)
          DO 15 IBASE=1,N_CON(LI+1,IFNCT)
           DO 10 IQ=1,N_SALC(KSALC,LI+1,ISHELL)
            INDEX=INDEX+1
            IND_SALC(IQ,IBASE,LI+1)=INDEX
   10      CONTINUE
   15     CONTINUE
   20    CONTINUE
C
C END CALCULATION OF SALC INDICES FOR REPRESENTATION K_REP
C
         DO 1000 IOCC=1,N_OCC(K_REP,ISPN)
          ITOT=ITOT+1
          I_SALC=KSALC-NDMREP(K_REP)
          DO 950 IROW=1,NDMREP(K_REP)
           I_SALC=I_SALC+1
           IWF=IWF+1
           I_LOCAL=0
           DO 900 LI=0,LSYMMAX(IFNCT)
            DO 890 MU=1,NDEG(LI+1)
             IMS=MU+NDEG(LI+1)*(I_SITE-1)
             DO 880 IBASE=1,N_CON(LI+1,IFNCT)
              I_LOCAL=I_LOCAL+1
              PSI(I_LOCAL,IWF,ILOC)=0.0D0
              IQ_BEG=IND_SALC(1,IBASE,LI+1)-1
              DO 800 IQ=1,N_SALC(KSALC,LI+1,ISHELL)
               PSI(I_LOCAL,IWF,ILOC)=PSI(I_LOCAL,IWF,ILOC)+
     &         PSI_COEF(IQ+IQ_BEG,IOCC,K_REP,ISPN)*
     &         U_MAT(IMS,IQ,I_SALC,LI+1,ILOC)
  800         CONTINUE
  880        CONTINUE
  890       CONTINUE
  900      CONTINUE
           IF(I_LOCAL.GT.MAXUNSYM)THEN
            PRINT*,'LORAVEL: MAXUNSYM MUST BE AT LEAST:',I_LOCAL
            CALL STOPIT
           END IF
           FACTOR=1.0D0!SQRT(OCCUPANCY(ITOT))

           EVALOCC(IWF)=EVLOCC(ITOT)
           MLOCAL=I_LOCAL
           DO 25 J_LOCAL=1,I_LOCAL
            PSI(J_LOCAL,IWF,ILOC)=FACTOR*PSI(J_LOCAL,IWF,ILOC)
   25      CONTINUE
  950     CONTINUE
 1000    CONTINUE
 1010   CONTINUE
 1020  CONTINUE
C
C      IF (IWF.NE.NWF) THEN
C       PRINT *,'LORAVEL: BIG BUG: NUMBER OF STATES IS INCORRECT'
C       PRINT *,'IWF,NWF:',IWF,NWF
C       CALL STOPIT
C      END IF
C NOW ROTATE FROM CANONICAL TO LOCALIZED REPRESENTATION....
C         DO ISPN=1,NSPN
C         PRINT*,'ISPN:',ISPN
C         DO IORB=1,MORB(1)
C         PRINT 3131,(TMAT(IORB,JWF,ISPN),JWF=1,NWFS(ISPN))
 3131     FORMAT(20F12.4)
C         END DO
C         END DO
      DO 2000 ISPN=1,NSPN
      DO 2000 J_LOCAL=1,MLOCAL
      DO IORB=1,MORB(ISPN)
        PHILOC(IORB)=0.0D0
             IF(ISPN.EQ.1)IWF=0
             IF(ISPN.EQ.2)IWF=NWFS(1)
        DO JWF=1,NWFS(ISPN)
             IWF=IWF+1
        PHILOC(IORB)=PHILOC(IORB)
     &              +PSI(J_LOCAL,IWF,ILOC)*TMAT(IORB,JWF,ISPN)
        END DO
      END DO
          IF(ISPN.EQ.1)JORB=0
          IF(ISPN.EQ.2)JORB=NWFS(1)
C     PRINT 3131,(PSI(J_LOCAL,KORB,ILOC),KORB=1,MORB(ISPN))
      DO IORB=1,MORB(ISPN)
          JORB=JORB+1
      PSI(J_LOCAL,JORB,ILOC)=PHILOC(IORB)  !COMMENT OUT ROTATION HERE
      END DO
C     PRINT 3131,(PSI(J_LOCAL,KORB,ILOC),KORB=1,MORB(ISPN))
C     DO IORB=MORB(ISPN)+1,NWFS(ISPN)
C         JORB=JORB+1
C     PSI(J_LOCAL,JORB,ILOC)=0.0D0
C     END DO
 2000 CONTINUE
C END OF ROTATION....
       RETURN
       END
