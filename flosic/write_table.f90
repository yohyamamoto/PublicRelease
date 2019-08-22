! UTEP Electronic Structure Lab (2019)

!Subroutine to write Table file required for scaled LBFGS

subroutine write_table
logical :: EXIST

inquire(file='Table',EXIST=EXIST)
if(EXIST) then
  return
else
  open(86,file='Table')
  write(86,'(A)') "0.50           100.00          101.00          102.00          103.00"
  write(86,'(A)') "0.50           100.00          101.00          102.00          103.00"
  write(86,'(A)') "0.50           4.00            101.00          102.00          103.00"
  write(86,'(A)') "0.50           4.00            101.00          102.00          103.00"
  write(86,'(A)') "0.40           4.00            101.00          102.00          103.00"
  write(86,'(A)') "0.30           4.00            101.00          102.00          103.00"
  write(86,'(A)') "0.30           3.50            101.00          102.00          103.00"
  write(86,'(A)') "0.30           2.50            101.00          102.00          103.00"
  write(86,'(A)') "0.30           2.00            101.00          102.00          103.00"
  write(86,'(A)') "0.30           2.50            101.00          102.00          103.00"
  write(86,'(A)') "0.20           2.09            8.00            102.00          103.00"
  write(86,'(A)') "0.20           1.83            8.00            102.00          103.00"
  write(86,'(A)') "0.10           1.33            5.00            102.00          103.00"
  write(86,'(A)') "0.10           1.19            5.00            102.00          103.00"
  write(86,'(A)') "0.05           1.05            4.00            102.00          103.00"
  write(86,'(A)') "0.05           0.88            4.00            102.00          103.00"
  write(86,'(A)') "0.05           0.81            3.00            102.00          103.00"
  write(86,'(A)') "0.04           0.72            3.00            102.00          103.00"
  write(86,'(A)') "0.03           0.66            2.43            7.00            103.00"
  write(86,'(A)') "0.03           0.63            2.23            7.00            103.00"
  write(86,'(A)') "0.03           0.60            2.28            7.00            103.00"
  write(86,'(A)') "0.02           0.54            2.24            7.00            103.00"
  write(86,'(A)') "0.02           0.53            2.00            7.00            103.00"
  write(86,'(A)') "0.02           0.48            2.21            7.00            103.00"
  write(86,'(A)') "0.02           0.46            2.46            7.00            103.00"
  write(86,'(A)') "0.02           0.78            2.14            7.00            103.00"
  write(86,'(A)') "0.02           0.61            2.11            7.00            103.00"
  write(86,'(A)') "0.02           0.39            1.86            7.00            103.00"
  write(86,'(A)') "0.02           0.55            2.34            8.00            103.00"
  write(86,'(A)') "0.01           0.37            1.94            7.00            103.00"
  write(86,'(A)') "0.01           0.36            1.75            7.00            103.00"
  write(86,'(A)') "0.01           0.34            1.49            7.00            103.00"
  write(86,'(A)') "0.01           0.33            1.41            7.00            103.00"
  write(86,'(A)') "0.01           0.31            1.38            6.00            103.00"
  write(86,'(A)') "0.01           0.30            1.22            6.00            103.00"
  write(86,'(A)') "0.01           0.28            1.14            6.00            103.00"
  close(86)
  return
end if
end subroutine write_table

