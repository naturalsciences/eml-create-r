# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/lib/jvm/jdk1.8.0_162')
options(java.parameters="-Xmx2g")
source('connections.R')
library(rJava)

# Output Java version
.jinit()
#print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)


# Create connection driver and open connection
jdbcDriver <- JDBC(driverClass="org.postgresql.Driver", classPath="/home/thomas/.m2/repository/org/postgresql/postgresql/42.2.2.jre7/postgresql-42.2.2.jre7.jar")

# Query on the Oracle instance name.
#instanceName <- dbGetQuery(jdbcConnection, "select  * from SELECT_EML")
#print(instanceName["IND_PUBLIC"])



rows = function(tab) lapply(
  seq_len(nrow(tab)),
  function(i) unclass(tab[i,,drop=F])
)

pgresults = function(query) {
  jdbcConnection <- dbConnect(jdbcDriver, pgString,pgUser,pgPassword)
  instanceName <- dbGetQuery(jdbcConnection, query)
  dbDisconnect(jdbcConnection)
  df <- data.frame(instanceName)
  return(rows(df))
}

