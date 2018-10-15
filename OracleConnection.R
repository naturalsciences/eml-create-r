# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/lib/jvm/jdk1.8.0_162')
options(java.parameters="-Xmx2g")
library(rJava)

# Output Java version
.jinit()
#print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)

# Create connection driver and open connection
jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="/home/thomas/.m2/repository/com/oracle/ojdbc14/10.2.0.3.0/ojdbc14-10.2.0.3.0.jar")

# Query on the Oracle instance name.
#instanceName <- dbGetQuery(jdbcConnection, "select  * from SELECT_EML")
#print(instanceName["IND_PUBLIC"])



rows = function(tab) lapply(
  seq_len(nrow(tab)),
  function(i) unclass(tab[i,,drop=F])
)

oraresults = function(query) {
  jdbcConnection <- dbConnect(jdbcDriver, oraString, oraUser, oraPassword)
  instanceName <- dbGetQuery(jdbcConnection, query)
  dbDisconnect(jdbcConnection)
  df <- data.frame(instanceName)
  return(rows(df))
}

