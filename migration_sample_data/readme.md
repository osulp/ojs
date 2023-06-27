## Guide to sample data

* The `article_pdfs/` directory contains four PDF files from OLA Quarterly 26(2) ([Link to issue on OJS3](https://journals3.oregondigital.org/olaq/issue/view/vol26_iss2)). The files represent a sampling of contents from different OJS "sections": two articles, a table of contents, and an introduction. 
  * __These can be used to experiment with publication workflows within OJS, including the regular submission/review workflow and the QuickSubmit plugin workflow.__
* The `ojs3_exports/` directory contains XML files for journal issues originally created in OJS3 and exported using the Native XML plugin. Content files are embedded as base64 within the XML. 
  * __You should be able to use the Native XML plugin to import these XML files as full issues into another OJS 3.3 instance.__
  * `ojs3_nwelearn.xml` contains two complete issues of the Northwest eLearning Journal
  * `ojs3_olaq_27-1.xml` and `ojs3_olaq_27-2.xml` each contain one complete issue of OLA Quarterly -- 27(1) and 27(2), respectively
* The `ojs2_exports/` directory contains XML files for journal issues exported from OJS2 using the Articles & Issues XML plugin. Content files are embedded as base64 within the XML.
  * __These need to be transformed to the appropriate XML schema before importing to any version of OJS3.__
  * They were transformed and imported to OJS 3.1.4 using an XML script and are semi-functional in both our `ojs-test` and `journals` site (restricted access for both). They can be browsed, viewed, and downloaded, but some cannot be edited due to the numeric identifier issue. 
  * `od2_trforum_56-1.xml` contains the complete issue of Journal of the Transportation Research Forum, 56(1) ([Link to issue on OJS3](https://journals3.oregondigital.org/trforum/issue/view/538)). This is meant to be "plain vanilla" content.
  * `od2_ForestPhytophthora_2-1.xml` contains the complete issue of Forest Phytophthoras, 2(1) ([Link to issue on OJS3](https://journals3.oregondigital.org/ForestPhytophthora/issue/view/266)). This issue's submission files are in HTML. The issue has a combination of default numeric and custom non-numeric identifiers.
  * `od2_CatalogOSAC_2-1.xml` contains the complete issue of Catalog: Oregon State Arthropod Collection, 2(1) ([Link to issue on OJS3](https://journals3.oregondigital.org/CatalogOSAC/article/view/4321)). There is only one submission in this issue, but it has a supplementary file as well.


## Guide to transform

The XSL transform stylesheet `ojs2-ojs3_1_4_transform.xsl` was used to transform OJS2 exports to the OJS 3.1.4 schema. The output was used to import the majority of our OJS content into OJS3 prior to upgrading to version 3.3. 

The XML document `ojs2_mets_data.xml` is essentially a structured list of every bit of content in OJS2, crucially including the OJS2 submission IDs and URLs to full text items. It was compiled from a directory of OJS2 METS exports using the additional XSL transform `ojs2_compile_METS.xsl` and is up to date as of end of March 2023.

The XML schema was significantly changed for 3.3 and the `ojs2-ojs3_3_0_transform.xsl` stylesheet is a work in progress to transform OJS2 exports for OJS 3.3.0. As of June 2023 the output can be uploaded with the Native XML import tool but several bugs are still being addressed.  

The OJS Native schema files are available on Github:

* native.xsd https://github.com/pkp/ojs/blob/stable-3_3_0/plugins/importexport/native/native.xsd; which includes:
* pkp-native.xsd https://github.com/pkp/pkp-lib/blob/stable-3_3_0/plugins/importexport/native/pkp-native.xsd; which includes:
* importexport.xsd https://github.com/pkp/pkp-lib/blob/stable-3_3_0/xml/importexport.xsd
