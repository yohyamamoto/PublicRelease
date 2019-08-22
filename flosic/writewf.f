C UTEP Electronic Structure Lab (2019)
C
       SUBROUTINE WRITEWF               
       use common2,only : RIDT, N_BARE, N_CON, LSYMMAX, N_POS, NFNCT
       use common3,only : RMAT
       use common5,only : PSI, NWF
! Conversion to implicit none.  Raja Zope Thu Aug 17 14:35:07 MDT 2017

!      INCLUDE  'PARAMAS'  
       INCLUDE  'PARAMA2'  

       INTEGER :: I_POS, IBARE, ICON, IERR, IFNCT, ILOC, ISHDUM, NMAX
       INTEGER :: ISHELLA, ISIZE, IWF, J, J_POS, L_NUC, LI, LMAX1, M_NUC, MU, MUT
       INTEGER ::  MU, MUT

       REAL*8 :: SYMBOL , FACTOR
       SAVE
       PARAMETER (NMAX=MPBLOCK)
       LOGICAL ICOUNT
C       COMMON/TMP1/COULOMB(MAX_PTS),RHOG(MAX_PTS,KRHOG,MXSPN)
C       COMMON/TMP2/PSIG(NSPEED,10),GAUS(NSPEED)  
C     &  ,PTS(NSPEED,3),BARE(NSPEED,6,3,MAX_CON)
C     &  ,RVECA(3,MX_GRP),ICOUNT(MAX_CON,3)
       REAL*8,ALLOCATABLE :: PSIG(:,:),GAUS(:),PTS(:,:)
     &  ,BARE(:,:,:,:),RVECA(:,:)
C
C SCRATCH COMMON BLOCK FOR LOCAL ARRAYS
C
       LOGICAL LGGA,IUPDAT
       DIMENSION ISIZE(3)
       DATA ISIZE/1,3,6/
       
       ALLOCATE(PSIG(NSPEED,10),STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR ALLOCATING PSIG'
       ALLOCATE(GAUS(NSPEED),STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR ALLOCATING GAUS'
       ALLOCATE(BARE(NSPEED,6,3,MAX_CON),STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR ALLOCATING BARE'
       ALLOCATE(RVECA(3,MX_GRP),STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR ALLOCATING PSIG'

       OPEN(20,FILE='WAVEFUNCTIONS')
       DO 1000 IWF=1,NWF
       WRITE(20,*)'WAVEFUNCTION:',IWF
        ISHELLA=0
C
C FOR ALL CENTER TYPES
C
        DO 86 IFNCT=1,NFNCT
         LMAX1=LSYMMAX(IFNCT)+1
C
C FOR ALL POSITIONS OF THIS CENTER
C
         DO 84 I_POS=1,N_POS(IFNCT)
          ISHELLA=ISHELLA+1
C
C GET SYMMETRY INFO
C
          CALL OBINFO(1,RIDT(1,ISHELLA),RVECA,M_NUC,ISHDUM)
          IF(NWF.GT.MAX_OCC)THEN
           PRINT *,'WRITEWF: MAX_OCC MUST BE AT LEAST:',NWF
           CALL STOPIT
          END IF
C
C FOR ALL EQUIVALENT POSITIONS OF THIS ATOM
C
          DO 82 J_POS=1,M_NUC
C
C UNSYMMETRIZE 
C
           CALL UNRAVEL(IFNCT,ISHELLA,J_POS,RIDT(1,ISHELLA),
     &                  RVECA,L_NUC,1)
           IF(L_NUC.NE.M_NUC)THEN
            PRINT *,'WRITEWF: PROBLEM IN UNRAVEL'
            CALL STOPIT
           END IF
           WRITE(20,100)(RVECA(J,J_POS),J=1,3)
           WRITE(20,*)' '
 100       FORMAT(' ',3F12.6, '  CENTER ')
            CALL GTBARE(IFNCT,BARE,GAUS)
            DO 79 IBARE=1,N_BARE(IFNCT)
                   DO MUT=1,10
                   PSIG(IBARE,MUT)=0.0D0
                   END DO
             ILOC=0
             DO 78 LI=1,LMAX1
              DO MU=1,ISIZE(LI)
                  IF(LI.EQ.1)MUT=MU
                  IF(LI.EQ.2)MUT=MU+1
                  IF(LI.EQ.3)MUT=MU+4
               DO ICON=1,N_CON(LI,IFNCT)
                ILOC=ILOC+1
                FACTOR=PSI(ILOC,IWF,1)
                PSIG(IBARE,MUT)=
     &          PSIG(IBARE,MUT)+FACTOR*BARE(IBARE,MU,LI,ICON)
               END DO  
              END DO  
   78        CONTINUE
             WRITE(20,20) GAUS(IBARE)
             WRITE(20,20) PSIG(IBARE,1)
             WRITE(20,20)(PSIG(IBARE,J),J=2,4)
             WRITE(20,20)(PSIG(IBARE,J),J=5,10)
             WRITE(20,*)' '
 20          FORMAT(' ',6G12.4) 
   79        CONTINUE
   80      CONTINUE
   82     CONTINUE
   84    CONTINUE
   86   CONTINUE
 1000  CONTINUE
       DEALLOCATE(PSIG,STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR DEALLOCATING PSIG'
       DEALLOCATE(GAUS,STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR DEALLOCATING GAUS'
       DEALLOCATE(BARE,STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR DEALLOCATING BARE'
       DEALLOCATE(RVECA,STAT=IERR)
       IF(IERR/=0)WRITE(6,*)'WRITEWF:ERROR DEALLOCATING PSIG'
       RETURN
       END
