# How to use

Upload this folder to server. 

Edit 'Main.bat'.

Set 'DataFolder='

Let zabbix agent run this customized script.

# How to make a new holiday table

Let us assume that we need make 2018 holiday table.

Download a template. I recommand "https://www.timeanddate.com/holidays/china/".

Click 'Change Holidays'. Select 'Federal/national holidays', 'Common Local', 'Weekend' if they exist.

Copy the following table and paste it into Excel.

Change the format of line 'Date' to 'yyyymmdd'. Make sure it look like '20180101'.

Save it as 'HolidaysChina[Year].csv'. For 2018, it is 'HolidaysChina2018.csv'.

If this file does NOT contain 'Special Working Day' in line 'Holiday Name', you need add them manually.

For 'Special Working Day', you can get them from gov's website.

For example of 2018, "http://www.gov.cn/xinwen/2017-11/30/content_5243589.htm" and "http://www.gov.cn/zhengce/content/2017-11/30/content_5243579.htm".

We add 20180211 as a 'Special Working Day':

```
 20180101,Monday,New Year's Day,National holiday
 20180102,Tuesday,New Year's weekend,Common Local holidays
+20180211,Sunday,Special Working Day,Weekend
 20180215,Thursday,Spring Festival Eve,National holiday
 20180216,Friday,Chinese New Year,National holiday
```

After adding all 'Special Working Day', we finish the 2018 holiday table.
