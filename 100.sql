 /*使用loop循环求前100 个自然数 的和*/
  /
 set serveroutput on
 
 declare
   sum_i int:= 0;
   i int:= 0;
 begin
   loop
     i:=i+1;
     sum_i:=sum_i+i;
     exit when i = 100;
   end loop;
   dbms_output.put_line('前100个自然数的和是: ' || sum_i);
 end;
 
 
 
 /*add query sql*/

 select * from emp;