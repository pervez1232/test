require 'rubygems'
require 'active_record'

# Change the details of First Database for Connection.
adapter1  = "postgresql"
host1     = "192.168.1.36"
port1     = "5433"
username1 = "paras"
password1 = "paras123!"
database1 = "parasdemome_18feb16"

# Change the details of Second Database for Connection.
adapter2  = "postgresql"
host2     = "192.168.4.145"
port2     = "5435"
username2 = "paras"
password2 = "paras123!"
database2 = "aarl_27oct15"

f = File.open("db_diff_new.txt","w+")
ActiveRecord::Base.establish_connection(:adapter => adapter1, :port=>port1, :host => host1, :username => username1, :password => password1, :database => database1)
db_1_tables = ActiveRecord::Base.connection.tables.sort

ActiveRecord::Base.establish_connection(:adapter => adapter2, :port => port2, :host => host2, :username => username2, :password => password2, :database => database2)
db_2_tables = ActiveRecord::Base.connection.tables.sort

common_tables = db_1_tables.collect{|c| db_2_tables.include?(c) ? c : nil}.compact 

count1 = 1
f.puts "   COMMON TABLES   "
f.puts "------------------------------------------------------"
for et in common_tables
        f.puts count1.to_s + ".\t" + et.to_s
        count1 += 1
end
f.puts "------------------------------------------------------\n\n"


first_db_extra = db_1_tables.collect{|t| db_2_tables.include?(t) ? nil : t }.compact

count1 = 1
f.puts "   " + database1.upcase + "'s DATASASE EXTRA TABLES   "
f.puts "-----------------------------+-------------------------"
for et in first_db_extra
        f.puts count1.to_s + ".\t" + et.to_s
        count1 += 1
end
f.puts "------------------------------------------------------\n\n"

second_db_extra = db_2_tables.collect{|t| db_1_tables.include?(t) ? nil : t }.compact

count1 = 1
f.puts "   " + database2.upcase + "'s DATASASE EXTRA TABLES   "
f.puts "------------------------------------------------------"
for et in second_db_extra
        f.puts count1.to_s + ".\t" + et.to_s
        count1 += 1
end
f.puts "------------------------------------------------------\n\n"

for et in common_tables
 ActiveRecord::Base.establish_connection(:adapter => adapter1, :host => host1, :username => username1, :password => password1, :database => database1)
first_db_table_column_objs = ActiveRecord::Base.connection.columns(et)
first_db_table_columns = first_db_table_column_objs.collect {|cn| [cn.name,cn.sql_type] }

ActiveRecord::Base.establish_connection(:adapter => adapter2, :host => host2, :username => username2, :password => password2, :database => database2)
second_db_table_column_objs = ActiveRecord::Base.connection.columns(et)
second_db_table_columns = second_db_table_column_objs.collect {|cn| [cn.name,cn.sql_type] }

first_extra = first_db_table_columns.collect{|s| second_db_table_columns.include?(s) ? nil : s }.compact

second_extra = second_db_table_columns.collect{|s| first_db_table_columns.include?(s) ? nil : s }.compact

table1 = database1.upcase + "'s Table Extra"
table2 = database2.upcase + "'s Table Extra"
if first_extra.length!=0 || second_extra.length!=0
f.puts "\n\n--------------------------------------------------------------------------------------"
f.puts "|Diffrence for Table : " + et.to_s.ljust(62) + "|"
f.puts "--------------------------------------------------------------------------------------"
f.puts "|" + table1.to_s.ljust(44) + table2.to_s.ljust(40) + "|"
f.puts "|.......................................     .....................................   |"
flen = first_extra.length
slen = second_extra.length
if flen > slen
lcount = flen
else
lcount = slen
end
for i in 0...lcount
if first_extra[i]
f1 = (first_extra[i][0] + "(" + first_extra[i][1] + ")").ljust(40)  
else
f1 = " ".ljust(40)
end
if second_extra[i]
f2 = (second_extra[i][0] + "(" + second_extra[i][1] + ")" ).ljust(40) 
else
f2 = " ".ljust(40)
end
f.puts "|" + f1 + "    " + f2 + "|"
end
f.puts "--------------------------------------------------------------------------------------"
end

end

  
