# How to install Spark:
# http://www.eaiesb.com/blogs/?p=334

# Issue with permissions;
# https://github.com/rstudio/sparklyr/issues/48

# C:\Hadoop\bin\winutils.exe chmod 777 C:\tmp\hive
# cd C:\spark-2.3.2-bin-hadoop2.7\bin

require(sparklyr)
require(dplyr)
Sys.getenv("SPARK_HOME")

spark_config()
sc <- spark_connect(master = "local", 
                    spark_home = Sys.getenv("SPARK_HOME"),
                    method = "shell")

# C:\Program Files\Java\jdk-11.0.1\

# from gitHub
# https://github.com/rstudio/sparklyr#installation
install.packages("sparklyr")
spark_install(version = "2.3.2")
devtools::install_github("rstudio/sparklyr")

sc <- spark_connect(master = "local")
