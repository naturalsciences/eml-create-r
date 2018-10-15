library("EML")
library("pracma")
library("rlist")
source('OracleConnection.R')
source('PostgresConnection.R')
thomas <- new(
  "metadataProvider",
  individualName = new ("individualName", givenName="Thomas", surName="Vandenberghe"),
  electronicMail = "tvandenberghe@naturalsciences.be",
  organizationName = "Royal Belgian Institute for Natural Sciences",
  positionName="Data manager",
  userId = set_userId("http://orcid.org/0000-0002-9269-6548",  directory =
                        "http://orcid.org/")
)

serge <- new(
  "associatedParty",
  individualName = new ("individualName", givenName="Serge", surName="Scory"),
  electronicMail = "sscory@naturalsciences.be",
  organizationName = "Royal Belgian Institute for Natural Sciences",
  positionName="Head of BMDC",
  role = "contentProvider",
  userId = set_userId("http://orcid.org/0000-0003-2692-8651", directory =
                        "http://orcid.org/")
)


patrick <- new(
  "associatedParty",
  individualName = new ("individualName", givenName="Patrick", surName="Semal"),
  electronicMail = "psemal@naturalsciences.be",
  organizationName = "Royal Belgian Institute for Natural Sciences",
  positionName="Head of Section Scientific Heritage",
  role = "contentProvider"
)

contact <- new("contact",
               electronicMail = "info@bedic.be",
               organizationName = "Biodiversity and Ecological Data and Information Centre - Royal Belgian Institute for Natural Sciences")


oraresults <- oraresults(
  "select
  title_en,
  null as title_nl,
  null as title_fr,
  abstract,
  acronym,
  null as name,
  null as citation,
  scope,
  funding_agency,
  institute_name,
  institute_dept_abbrev,
  boss,
  boss_email,
  boss_role,
  subboss,
  subboss_email,
  subboss_role,
  geographic_coverage,
  min_lon,
  max_lon,
  min_lat,
  max_lat,
  start_date,
  end_date,
  pub_date,
  class_taxonomic_coverage,
  order_taxonomic_coverage,
  keywords,
  null as nb_spec,
  null as ig_num,
  null as id
  from select_eml order by acronym"
)
pgresults <- pgresults(
  "select
  TITLE_EN as \"TITLE_EN\",
  TITLE_NL as \"TITLE_NL\",
  TITLE_FR as \"TITLE_FR\",
  ABSTRACT as \"ABSTRACT\",
  CODE AS \"ACRONYM\",
  NAME as \"NAME\",
  CITATION as \"CITATION\",
  SCOPE as \"SCOPE\",
  NULL AS \"FUNDING_AGENCY\",
  INSTITUTE_NAME as \"INSTITUTE_NAME\",
  INSTITUTE_DEPT_ABBREV as \"INSTITUTE_DEPT_ABBREV\",
  BOSS as \"BOSS\",
  BOSS_EMAIL as \"BOSS_EMAIL\",
  BOSS_ROLE as \"BOSS_ROLE\",
  SUBBOSS as \"SUBBOSS\",
  SUBBOSS_EMAIL as \"SUBBOSS_EMAIL\",
  SUBBOSS_ROLE as \"SUBBOSS_ROLE\",
  GEOGRAPHIC_COVERAGE as \"GEOGRAPHIC_COVERAGE\",
  MIN_LON as \"MIN_LON\",
  MAX_LON as \"MAX_LON\",
  MIN_LAT as \"MIN_LAT\",
  MAX_LAT as \"MAX_LAT\",
  START_DATE as \"START_DATE\",
  END_DATE as \"END_DATE\",
  NULL as \"PUB_DATE\",
  CLASS_TAXONOMIC_COVERAGE as \"CLASS_TAXONOMIC_COVERAGE\",
  ORDER_TAXONOMIC_COVERAGE as \"ORDER_TAXONOMIC_COVERAGE\",
  KEYWORDS as \"KEYWORDS\",
  NB_SPEC as \"NB_SPEC\",
  IG_NUM as \"IG_NUM\",
  ID as \"ID\"
  from SELECT_EML_MARINE"
)
print ("working")
#data <- rbind(oraresults, pgresults, fill=TRUE)
for (el in pgresults) {
  name = el$NAME
  title_en = el$TITLE_EN
  title_nl = el$TITLE_NL
  title_fr = el$TITLE_FR
  acronym = el$ACRONYM
  citation_text = el$CITATION
  scope = el$SCOPE
  if (!is.na(acronym)) {
    print(paste("processing ", acronym))
  }
  abstract_text = el$ABSTRACT
  institute = el$INSTITUTE_NAME
  dept = el$INSTITUTE_DEPT_ABBREV
  boss_text = el$BOSS
  subboss_text = el$SUBBOSS
  boss_email = el$BOSS_EMAIL
  subboss_email = el$SUBBOSS_EMAIL
  boss_role = el$BOSS_ROLE
  subboss_role = el$SUBBOSS_ROLE
  
  start = el$START_DATE
  stop = el$END_DATE
  pub_date = el$PUB_DATE
  w = el$MIN_LON
  e = el$MAX_LON
  n = el$MAX_LAT
  s = el$MIN_LAT
  geodesc = el$GEOGRAPHIC_COVERAGE
  #as.na(boss)
  #as.na(subboss)
  if (nchar(el$CLASS_TAXONOMIC_COVERAGE) < nchar(el$ORDER_TAXONOMIC_COVERAGE)) {
    taxodesc = el$CLASS_TAXONOMIC_COVERAGE
    taxolevel = 'Class'
  } else{
    taxodesc = el$ORDER_TAXONOMIC_COVERAGE
    taxolevel = 'Order'
  }
  if (!is.null(el$KEYWORDS)) {
    keywords <- unlist(strsplit(el$KEYWORDS, ", "))
  }
  
  creators=list() 
  if (string_is_not_null_or_empty(boss_text)) {
    boss <- new(
      "creator",
      individualName = boss_text,
      organizationName = paste(institute, ' - ', dept)
    )
    citation_authors=boss_text;
    #list.append(creators, boss)
    #creators<-c(creators,boss)
    if(!identical(creators[length(creators)],boss)) {creators[[length(creators)+1]] <- boss}
    
  }
  
  if (string_is_not_null_or_empty(subboss_text)) {
    subboss <- new(
      "creator",
      individualName = subboss_text,
      organizationName = paste(institute, ' - ', dept)
    )
    citation_authors=paste(citation_authors, subboss_text, sep = "")
    #list.append(creators, subboss)
    #creators<-c(creators,subboss)
   if(!identical(creators[length(creators)],subboss)) {creators[[length(creators)+1]] <- subboss}
    
  }
  #print (subboss_text)
  #print(boss_text)
  #if(string_is_not_null_or_empty(subboss_text) && string_is_not_null_or_empty(boss_text) && !strcmp(subboss_text, boss_text)){
  # creators <- list(subboss, boss)
  #
  # citation=paste("<citation>",boss,", ",subboss_text," (",substr(pub_date, 0, 4) ,") ",title_en," (",acronym,")","</citation>", sep = "")
  
  #}else if(string_is_not_null_or_empty(boss_text)){
  #   creators <- list(boss)
  #   citation=paste("<citation>",boss," (",substr(pub_date, 0, 4) ,") ",title_en," (",acronym,")","</citation>", sep = "")
  #}

  if (scope == 'collection') {
    associatedParty = patrick
  }
  else if (scope == 'BMDC'){
    associatedParty = serge
    geodesc='Belgian part of the North Sea (http://marineregions.org/mrgid/26567)'
  }
  do_stuff()
}
print("Program ended")


do_stuff = function() {
  geographicCoverage <-
    new (
      "geographicCoverage",
      geographicDescription = geodesc,
      boundingCoordinates = new(
        "boundingCoordinates",
        westBoundingCoordinate = toString(w),
        eastBoundingCoordinate = toString(e),
        northBoundingCoordinate = toString(n),
        southBoundingCoordinate = toString(s)
      )
    )
  
  temporalCoverage <-
    new ("temporalCoverage",
         rangeOfDates = new(
           "rangeOfDates",
           beginDate = new("beginDate", calendarDate = start),
           endDate = new("endDate", calendarDate = stop)
         ))
  
  taxonomicGroups <- unlist(strsplit(el$ORDER_TAXONOMIC_COVERAGE, ", "))
  taxonomicGroups[[length(taxonomicGroups)+1]] <- subboss
  taxonomicClassification = new (
    "taxonomicClassification",
    taxonRankName = taxolevel,
    taxonRankValue = taxodesc
  )
  taxonomicCoverage <-
    new (
      "taxonomicCoverage",
      
    )
  
  coverage <-
    new (
      "coverage",
      geographicCoverage = geographicCoverage,
      temporalCoverage = temporalCoverage,
      taxonomicCoverage = taxonomicCoverage
    )
  
  keywordSet <-
    c(new("keywordSet",
          keyword <- keywords))
  if (is.na(acronym)) {
    title_en <-
      new("title",
          value = title_en,
          lang = "en")
  } else{
    title_en <-
      new("title",
          value = paste(title_en, " (", acronym, ")", sep = ""),
          lang = "en")
  }
  title_nl <- new("title", value = title_nl, lang = "nl")
  title_fr <- new("title", value = title_fr, lang = "fr")
  print(length(creators))
  dataset <- new(
    "dataset",
    title = c(title_en, title_nl, title_fr),
    creator = creators,
    pubDate = as.character(format(Sys.Date(), '%Y-%m-%d')),
    intellectualRights = "<para>This work is licensed under a <ulink url=\"http://creativecommons.org/licenses/by/4.0/legalcode\"><citetitle>Creative Commons Attribution (CC-BY) 4.0 License</citetitle></ulink>.</para>",
    abstract = abstract_text,  #= new("abstract",abstract_text),
    alternateIdentifier = "",
    language="eng",
    associatedParty = associatedParty,
    additionalInfo="",
    distribution="",
    metadataProvider=thomas,
    keywordSet = keywordSet,
    coverage = coverage,
    contact = contact
  )
  
  eml <- new("eml",
             packageId = "f0cda3bf-2619-425e-b8be-8deb6bc6094d",
             # from uuid::UUIDgenerate(),
             system = "uuid",
             # type of identifier
             dataset = dataset,
             additionalMetadata=new ("metadata",create_additional_metadata())#create_additional_metadata()
)

  filename1=paste("./",acronym,".xml", sep = "");
  filename2=paste("./",acronym,"2.xml", sep = "");
  filename3=paste("./",acronym,"3.xml", sep = "");
  filename4=paste("./",acronym,"4.xml", sep = "");
    if (!file.exists(filename1)) {
      write_eml(eml, filename1)
      replace_in_file(filename1)
    }else if (!file.exists(filename2)) {
      write_eml(eml, filename2)
      replace_in_file(filename2)
    }else if (!file.exists(filename3)) {
      write_eml(eml, filename3)
      replace_in_file(filename3)
    }else{
      write_eml(eml, filename4)
      replace_in_file(filename4)
    }
}

replace_in_file=function(filename){
  tx  <- readLines(filename)
  tx  <- gsub(pattern = "&lt;", replace = "<", x = tx)
  tx  <- gsub(pattern = "&gt;", replace = ">", x = tx)
  writeLines(tx, con=filename)
}

string_is_not_null_or_empty=function(string){
 return (!is.null(string) && string != '' &&  string != ' ' && !is.na(string))
}

create_additional_metadata= function() {
  wrapper=c("<gbif>","</gbif>")
  tm <- as.POSIXlt(Sys.time(), "UTC", "%Y-%m-%dT%H:%M:%S")
  #2018-07-09T05:43:57.925+02:00
  datestamp=paste("<dateStamp>",strftime(tm , "%Y-%m-%dT%H:%M:%S%z"),"</dateStamp>", sep = "")
  result =paste("<gbif>",datestamp,"<hierarchyLevel>dataset</hierarchyLevel>",citation_text,"</gbif>", sep = "")
  

                    #<collection>
                    #   <parentCollectionIdentifier>NO ID</parentCollectionIdentifier>
                    #   <collectionIdentifier>MY ID</collectionIdentifier>
                    #   <collectionName>This collection</collectionName>
                    # </collection>
                    # <collection>
                    #   <parentCollectionIdentifier>MY ID</parentCollectionIdentifier>
                    #   <collectionIdentifier>ITS ID</collectionIdentifier>
                    #   <collectionName>Subcollection</collectionName>
                    # </collection>
                    # <specimenPreservationMethod>glycerin</specimenPreservationMethod>
                    # <dc:replaces>http://ipt.biodiversity.be/resource?id=test-chelicerata/v1.1.xml</dc:replaces>
                   
  return (result)
}