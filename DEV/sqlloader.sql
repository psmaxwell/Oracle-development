第十四章： 数据装载 sql loader(PPT-I-490-498) 
 
14.1 sql*loader：将外部数据（比如文本型）数据导入 oracle database。（用于数据导入、 不同类型数据库数据迁移）     

 
14.2 sql*loader 导入数据原理：在段（segment 表）insert 记录            1）conventional：将记录插入到 segment 的 HWM(高水位线）以下的块，要首先访问 bitmap ，来确定那些 block 有 free space      2）direct path：将记录插入到 segment 的 HWM(高水位线）以上的从未使用过的块， 绕过 db_buffer,不检查约束。还可以关闭 redo, 也支持并行操作，加快插入速度。 
 
例： SQL> create table emp1 as select * from emp where 1=2; 
 
SQL> insert into emp1 select * from emp;   //conventional 方式插入数据 
 
SQL> insert /*+ APPEND */ into emp1 select * from emp;        //direct path方式 插入数据, 必须 commit 后才能查看数据          14.3 sql*loader 用法 
 
SQLLDR keyword=value [,keyword=value,...] 
 
看帮助信息    $/u01/oracle/bin/sqlldr(回车）。如果要使用 direct path 方式，在命令行中使用关键字 direct=TRUE 
 
*考点：sql*loader 与 data dump 的一个区别：data dump 只能读取由它导出的文件，而 sql*loader 可以读取任何它能解析的第三方文件格式 
 
 
14.4 例子： 
 
1）模拟生成数据源 
 
11:02:13 SQL> select empno||','||ename||','||job||','||mgr||','||hiredate||','||sal||','||comm||','|| deptno from scott.emp;  
 
 
EMPNO||','||ENAME||','||JOB||','||MGR||','||HIREDATE||','||SAL||','||COMM||','|| DEPTNO ----------------------------------------------------------------------------------------------------------------------- 7369,SMITH,CLERK,7902,1980-12-17 00:00:00,800,,20 7499,ALLEN,SALESMAN,7698,1981-02-20 00:00:00,1600,300,30 7521,WARD,SALESMAN,7698,1981-02-22 00:00:00,1250,500,30 7566,JONES,MANAGER,7839,1981-04-02 00:00:00,2975,,20 

 
7654,MARTIN,SALESMAN,7698,1981-09-28 00:00:00,1250,1400,30 
7698,BLAKE,MANAGER,7839,1981-05-01 00:00:00,2850,,30 
7782,CLARK,MANAGER,7839,1981-06-09 00:00:00,2450,,10 
7788,SCOTT,ANALYST,7566,1987-04-19 00:00:00,3000,,20 
7839,KING,PRESIDENT,,1981-11-17 00:00:00,5000,,10 
7844,TURNER,SALESMAN,7698,1981-09-08 00:00:00,1500,0,30
7876,ADAMS,CLERK,7788,1987-05-23 00:00:00,1100,,20 
7900,JAMES,CLERK,7698,1981-12-03 00:00:00,950,,30 
7902,FORD,ANALYST,7566,1981-12-03 00:00:00,3000,,20 
7934,MILLER,CLERK,7782,1982-01-23 00:00:00,1300,,10 
 
14 rows selected. 
 
2)建个目录 
 
[oracle@timran]$mkdir -p /home/oracle/sqlload 
[oracle@timran]$cd /home/oracle/sqlload 
[oracle@timran sqlload]$vi emp.dat      --生成平面表       

  --------查看数据源 
[oracle@timran sqlload]$ more emp.dat 
7369,SMITH,CLERK,7902,1980-12-17 00:00:00,800,,20 
7499,ALLEN,SALESMAN,7698,1981-02-20 00:00:00,1600,300,30 
7521,WARD,SALESMAN,7698,1981-02-22 00:00:00,1250,500,30 
7566,JONES,MANAGER,7839,1981-04-02 00:00:00,2975,,20 
7654,MARTIN,SALESMAN,7698,1981-09-28 00:00:00,1250,1400,30 
7698,BLAKE,MANAGER,7839,1981-05-01 00:00:00,2850,,30 
7782,CLARK,MANAGER,7839,1981-06-09 00:00:00,2450,,10 
7788,SCOTT,ANALYST,7566,1987-04-19 00:00:00,3000,,20 
7839,KING,PRESIDENT,,1981-11-17 00:00:00,5000,,10 
7844,TURNER,SALESMAN,7698,1981-09-08 00:00:00,1500,0,30 
7876,ADAMS,CLERK,7788,1987-05-23 00:00:00,1100,,20 
7900,JAMES,CLERK,7698,1981-12-03 00:00:00,950,,30 
7902,FORD,ANALYST,7566,1981-12-03 00:00:00,3000,,20 
7934,MILLER,CLERK,7782,1982-01-23 00:00:00,1300,,10 
 
 
3）conventional 方式导入   
建立控制文件 
[oracle@work sqlldr]$ vi emp.ctl 
 
load data 

infile '/home/oracle/sqlload/emp.dat' insert              --insert 插入表必须是空表，非空表用 append 
into table emp1 
fields terminated by ',' 
optionally enclosed by '"' 
( empno, ename, job, mgr, hiredate, comm, sal, deptno) 
 
4)在 scott 下建立 emp1 表（内部表），只要结构不要数据 
 
11:10:13 SQL> create table emp1 as select * from emp where 1=2; 
 
5)执行导入（normal） 
[oracle@timran timran]$ sqlldr scott/scott control=emp.ctl log=emp.log   

SQL*Loader: Release 10.2.0.1.0 - Production on Thu Aug 11 12:18:36 2011 
Copyright (c) 1982, 2005, Oracle.  All rights reserved. 
Commit point reached - logical record count 14 
 
5)验证： 
11:07:12 SQL> 
11:07:12 SQL> select * from emp1; 
 
 
上例的另一种形式是将数据源和控制文件合并在.ctl 里描述 
 
[oracle@work sqlldr]$ vi emp.ctl 
load data 
infile * 
append 
into table emp1 
fields terminated  by   ',' 
optionally enclosed by '"' 
( empno, 
ename, 
job, 
mgr, 
hiredate, 
comm, 
sal, 
deptno) 
begindata
7369,SMITH,CLERK,7902,1980-12-17 00:00:00,800,,20 
7499,ALLEN,SALESMAN,7698,1981-02-20 00:00:00,1600,300,30 
7521,WARD,SALESMAN,7698,1981-02-22 00:00:00,1250,500,30 
7566,JONES,MANAGER,7839,1981-04-02 00:00:00,2975,,20 
7654,MARTIN,SALESMAN,7698,1981-09-28 00:00:00,1250,1400,30 
7698,BLAKE,MANAGER,7839,1981-05-01 00:00:00,2850,,30 
7782,CLARK,MANAGER,7839,1981-06-09 00:00:00,2450,,10 
7788,SCOTT,ANALYST,7566,1987-04-19 00:00:00,3000,,20 
7839,KING,PRESIDENT,,1981-11-17 00:00:00,5000,,10 
7844,TURNER,SALESMAN,7698,1981-09-08 00:00:00,1500,0,30 
7876,ADAMS,CLERK,7788,1987-05-23 00:00:00,1100,,20 
7900,JAMES,CLERK,7698,1981-12-03 00:00:00,950,,30 
7902,FORD,ANALYST,7566,1981-12-03 00:00:00,3000,,20 
7934,MILLER,CLERK,7782,1982-01-23 00:00:00,1300,,10 
 
[oracle@timran sqlload]$ sqlldr scott/scott control=emp.ctl log=emp.log 
 
Commit point reached - logical record count 15 
[oracle@timran sqlload]$  
[oracle@timran sqlload]$  
[oracle@timran sqlload]$  
[oracle@timran sqlload]$ ll 
总计 12 
-rw-r--r-- 1 oracle oinstall    1 07-17 11:09 emp.bad 
-rw-r--r-- 1 oracle oinstall  782 07-17 11:09 emp.ctl 
-rw-r--r-- 1 oracle oinstall 2055 07-17 11:09 emp.log 
[oracle@timran sqlload]$ more emp.bad 
 
11:09:34 SQL>SQL> select count(*) from emp1; 
 
  COUNT(*)
  ----------         
  28 