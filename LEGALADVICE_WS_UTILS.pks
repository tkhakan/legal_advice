CREATE OR REPLACE PACKAGE LEGALADVICE.LEGALADVICE_WS_UTILS AS
/******************************************************************************
   NAME:       LEGALADVICE_WS_UTILS
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/1/2009      GÜZIN GÖRGÜN       1. Created this package.
******************************************************************************/
 TYPE refcur IS REF CURSOR;
  
   PROCEDURE updateLAdviceMasterByInstId (
      p_call_no Number,
      p_instanceId  varchar2,
      p_return OUT NUMBER
   
   );
    PROCEDURE getdepartmantInfo( cur OUT refcur);
    PROCEDURE insertlegaladvicemaster (
      p_created_by         IN            VARCHAR2 DEFAULT NULL,
   --   p_create_date        IN            DATE DEFAULT NULL,
      p_department_code    IN            VARCHAR2 DEFAULT NULL,
      p_call_subject       IN            VARCHAR2 DEFAULT NULL,
      p_advice_type          IN            VARCHAR2 DEFAULT NULL,
      p_policy_type        IN            VARCHAR2 DEFAULT NULL,
      p_call_summary       IN            VARCHAR2 DEFAULT NULL,
      p_call_explanation   IN            VARCHAR2 DEFAULT NULL,
      p_state              IN            VARCHAR2 DEFAULT NULL,
      p_state_date         IN            DATE DEFAULT NULL,
      p_stated_by          IN            VARCHAR2 DEFAULT NULL,
      p_solution_code      IN            VARCHAR2 DEFAULT NULL,
      p_solution_date      IN            DATE DEFAULT NULL,
      p_solution_explanation IN          VARCHAR2 DEFAULT NULL,
      p_alternative_solution_r IN        NUMBER DEFAULT NULL,
      p_lawyer_receive_date    IN        DATE DEFAULT NULL,
      p_call_no                  OUT   NUMBER
   );
   
   PROCEDURE getlegaladvicequestions (
      cur                OUT      refcur
   );

    PROCEDURE insertLegalAdviceDetail (
      p_call_no                    NUMBER,
      p_order_no                   NUMBER,
      p_created_by                 VARCHAR2,
      p_create_date                DATE,
      p_owner                      VARCHAR2,
      p_state                      VARCHAR2,
      p_state_date                 DATE,
      p_stated_by                  VARCHAR2,
      p_call_explanation           VARCHAR2,
      p_department                 VARCHAR2,
      p_alternative_solution_exp   VARCHAR2,
      p_judicial_results           VARCHAR2,
      p_relevant_legislation       VARCHAR2,
      p_state_duration             NUMBER      
   );

    PROCEDURE findLawyer (
   
    
    p_policy_claim_type IN Varchar2,
    p_department_code IN Varchar2,
    cur OUT refcur    
      
   );
   
 
   
  Procedure UpdateSearchFlag(
  
  p_call_no NUMBER,
  p_searchable NUMBER);
  
  procedure getLAdviceMasterInfobyInstId(
  p_instance_id varchar2,
  cur OUT refcur
  );
  
  procedure getLAdviceMasterInfobyCallNo(
  p_call_no in varchar2,
  cur OUT refcur
  );
  
  procedure getLegalAdviceDetail(
  p_call_No number,
  cur OUT refcur
  );
  
  PROCEDURE getcallparameterlist (p_look_code IN VARCHAR2, cur OUT refcur);
  PROCEDURE updatecallstate (
      p_call_no      IN       NUMBER,
      p_state        IN       VARCHAR2,
      p_stated_by    IN       VARCHAR2,
      p_return       OUT      NUMBER
   );
 procedure getCategorization(
        p_policy_claim_type varchar2,
        p_department_code varchar2,
        cur OUT refcur
        );
        
        
 PROCEDURE getdepResponsibility(cur OUT refcur);
 PROCEDURE getbranchResponsibility(cur OUT refcur);

 PROCEDURE insertcategorization (
      p_policy_claim_type  IN            VARCHAR2 DEFAULT NULL,
      p_department_code    IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_userid      IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_firstname   IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_lastname    IN            VARCHAR2 DEFAULT NULL
      
   );
   
    
PROCEDURE insertbranchresponsibility (
      p_policy_claim_type  IN            VARCHAR2 DEFAULT NULL,      
      p_lawyer_userid      IN            VARCHAR2 DEFAULT NULL
--      p_lawyer_firstname   IN            VARCHAR2 DEFAULT NULL,
 --     p_lawyer_lastname    IN            VARCHAR2 DEFAULT NULL
   );


   
  PROCEDURE updatecategorization (
      p_policy_claim_type  IN            VARCHAR2 DEFAULT NULL,
      p_department_code    IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_userid      IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_firstname   IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_lastname    IN            VARCHAR2 DEFAULT NULL,
      p_return       OUT      NUMBER
   );
   
   PROCEDURE getNextOrderNo(
    p_call_no IN NUMBER,
    p_order_no OUT NUMBER
  );
  
    PROCEDURE getNextAttachmentId(
    p_call_no IN NUMBER,
    p_order_no IN NUMBER,
    p_attachment_id OUT NUMBER
  );

 PROCEDURE getAttachmentIds(
    p_call_no IN NUMBER,
    p_order_no IN NUMBER,
    cur OUT refcur
  );
    PROCEDURE getAttachmentInfo(
    p_call_no IN NUMBER,
    p_order_no IN NUMBER,
    cur OUT refcur
  );
  
    PROCEDURE getcallparameterdetails (
      p_parameter_code   IN       VARCHAR2,
      p_code             IN       VARCHAR2,
      cur                OUT      refcur
   );
      PROCEDURE updateLegalAdviceMaster (
      p_call_no            IN   NUMBER,
      p_call_subject       IN            VARCHAR2 DEFAULT NULL,
      p_call_summary       IN            VARCHAR2 DEFAULT NULL,
      p_call_explanation   IN            VARCHAR2 DEFAULT NULL,
      p_state              IN            VARCHAR2 DEFAULT NULL,
      p_state_date         IN            DATE DEFAULT NULL,
      p_stated_by          IN            VARCHAR2 DEFAULT NULL,
      p_solution_code      IN            VARCHAR2 DEFAULT NULL,
      p_solution_date      IN            DATE DEFAULT NULL,
      p_solution_explanation IN          VARCHAR2 DEFAULT NULL,
      p_alternative_solution_r IN        NUMBER DEFAULT NULL,
      p_lawyer_receive_date    IN        DATE DEFAULT NULL,
      p_owner             IN       VARCHAR2 DEFAULT NULL,
      p_elapsed_time         IN       VARCHAR2 DEFAULT NULL,
      p_policy_type          IN         VARCHAR2 DEFAULT NULL,
      p_advice_type          IN         VARCHAR2 DEFAULT NULL,
      p_searchable             IN       NUMBER DEFAULT NULL,
      p_solution_duration       IN       NUMBER DEFAULT NULL,
     p_result OUT NUMBER      
   );
      PROCEDURE removeAttachment (
        p_call_no IN NUMBER,
        p_order_no IN NUMBER,
        p_attachment_id IN NUMBER,
        p_return       OUT      NUMBER
  );
   PROCEDURE insertAttachment (
        p_call_no IN NUMBER,
        p_order_no IN NUMBER,
        p_attachment_id IN NUMBER,
        p_created_by IN VARCHAR2,
        p_explanation IN VARCHAR2,
        p_department_code IN VARCHAR2,
        p_content_type IN VARCHAR2,
        p_return       OUT      NUMBER
  
  
  );
  
PROCEDURE getdiffofsysandreceivetime (
      p_call_no           IN       NUMBER,
      cur                 OUT      refcur
   );
    PROCEDURE getfurtherinfotimes (
      p_call_no           IN       NUMBER,
      cur                 OUT      refcur
   );
 PROCEDURE getdetailedlegaladviceresult (
      p_call_no              IN       NUMBER,
      p_call_subject         IN       VARCHAR2,
      p_advice_type           IN       VARCHAR2,
      p_state                IN       VARCHAR2,
      p_created_by           IN       VARCHAR2,
      p_department_code      IN       VARCHAR2,
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      p_lawyer               IN       VARCHAR2,
      p_searchable           IN       NUMBER,
      p_state_filter         IN       NUMBER,
      p_username             IN       VARCHAR2,
      cur                    OUT      refcur
   );
  PROCEDURE getdiffofstateandreceivetime (
      p_call_no           IN       NUMBER,
      cur                 OUT      refcur
   );
PROCEDURE getfutherinfosearchresult (
      p_owner              IN       VARCHAR2,     
      cur                    OUT      refcur
   );
 
PROCEDURE getcompletedsearchresult (
      p_stated_by            IN       VARCHAR2,     
      cur                    OUT      refcur
   );
   
   PROCEDURE getcompletedsearchresultforUsr (
      p_created_by            IN       VARCHAR2,     
      cur                    OUT      refcur
   );
   
   PROCEDURE getlawyers(cur OUT refcur);
    PROCEDURE getlawyercount(count OUT NUMBER);
     PROCEDURE assignbranchresponsable (
      p_unit            IN       VARCHAR2 DEFAULT NULL,
      p_type            IN       VARCHAR2 DEFAULT NULL,
      p_lawyer_userid   IN       VARCHAR2 DEFAULT NULL,
      p_return          OUT      NUMBER
   );
   
    PROCEDURE assigndepresponsable (
      d_unit  IN     VARCHAR2 DEFAULT NULL,
      d_type  IN   VARCHAR2 DEFAULT NULL,
      d_lawyer_userid      IN    VARCHAR2 DEFAULT NULL,
   --   d_lawyer_firstname   IN    VARCHAR2 DEFAULT NULL,
   --   d_lawyer_lastname    IN    VARCHAR2 DEFAULT NULL,
      
      d_return   OUT   NUMBER
   );
    PROCEDURE insertdepresponsibility (
      p_department_code    IN            VARCHAR2 DEFAULT NULL,
      p_lawyer_userid      IN            VARCHAR2 DEFAULT NULL
    --  p_lawyer_firstname   IN            VARCHAR2 DEFAULT NULL,
    --  p_lawyer_lastname    IN            VARCHAR2 DEFAULT NULL
   );
   
  /* PROCEDURE findResponsibleLawyer (
    p_policy_claim_type IN Varchar2,
    p_department_code IN Varchar2,
    cur OUT refcur );
    */
    PROCEDURE getWeeksRequest (cur OUT refcur);
     PROCEDURE getRequestedDepartment (cur OUT refcur);
     PROCEDURE gettotalandelapsedtime (
      p_owner    IN       VARCHAR2,
      cur          OUT      refcur
   );
   PROCEDURE getStartedRequestAmount (
      cur          OUT      refcur
   );
   PROCEDURE getDividedRequests (
    p_owner    IN       VARCHAR2,
    cur OUT refcur
    );
    PROCEDURE getDepDependentRq (
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      cur                    OUT      refcur
   );
   PROCEDURE getAdvDependentRq (
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      cur                    OUT      refcur
   );
    PROCEDURE getLawDependentRq (
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      cur                    OUT      refcur
   );
    PROCEDURE updatelamasterForProcess (
      p_call_no                  IN       NUMBER,
      p_owner                    IN       VARCHAR2 DEFAULT NULL,
      p_result                   OUT      NUMBER
   );
   PROCEDURE getexplanationbystate (p_call_no NUMBER,p_state VARCHAR2, cur OUT refcur);
   PROCEDURE updateDetailsLastStateDate (
      p_call_no                  IN       NUMBER,
      p_state                    IN       VARCHAR2 DEFAULT NULL,
      p_state_date               IN       DATE,
      p_result                   OUT      NUMBER
   );
    PROCEDURE updatelabyrecallinstid (
      p_call_no            NUMBER,
      p_instanceid         VARCHAR2,
      p_return       OUT   NUMBER
   );
   PROCEDURE getInstanceIdFromRecall (
      p_recall   IN       VARCHAR2,
      cur         OUT      refcur
   );
   
 PROCEDURE updatelawyer (
      p_lawyer_id     IN       VARCHAR2,
      p_validity_end_date  IN      DATE,
      p_return       OUT   NUMBER
   );
   
   
   PROCEDURE insertlawyer (
      p_lawyer_id  IN            VARCHAR2 ,      
      p_lawyer_name      IN            VARCHAR2,
      p_lawyer_surname  IN            VARCHAR2 ,  
      p_lawyer_order  IN            INTEGER ,  
      p_lawyer_validity_start_date  IN            DATE   
      

   );
   
  PROCEDURE updatesla (
      p_advice_type     IN       VARCHAR2,
      p_policy_type     IN       VARCHAR2,
      p_sla             IN       NUMBER,
      p_return         OUT       NUMBER
   );
  
  
PROCEDURE getslalist (
      p_advice_type     IN       VARCHAR2,
      p_policy_type     IN       VARCHAR2,
      cur                OUT      refcur
   );
   
   PROCEDURE getpolicy(
      p_advice_type   IN VARCHAR2,
      cur                OUT      refcur
   );
PROCEDURE getlegaladviceparameters(
        p_look_up_code IN VARCHAR2,
        p_code         IN VARCHAR2,
        cur          OUT    refcur
   ); 
   
PROCEDURE insertsurvey(
      p_call_no          IN            NUMBER ,      
      p_answer1          IN            VARCHAR2,
      p_answer2          IN            VARCHAR2, 
      p_message          IN            VARCHAR2   
    );  
    
PROCEDURE getsurvey(
    p_callno IN NUMBER,
    cur OUT refcur); 

 PROCEDURE gettotalandelapsedtimebyyear (
      p_year     IN       NUMBER,
      p_owner    IN       VARCHAR2,
      cur          OUT      refcur
   );

PROCEDURE getStartedRequestAmountByYear (
      p_year     IN       NUMBER,
      cur          OUT      refcur
   );
   
   
    PROCEDURE getdetailedlegaladviceresult2 (
      p_call_no              IN       NUMBER,
      p_call_subject         IN       VARCHAR2,
      p_advice_type           IN       VARCHAR2,
      p_state                IN       VARCHAR2,
      p_created_by           IN       VARCHAR2,
      p_department_code      IN       VARCHAR2,
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      p_lawyer               IN       VARCHAR2,
      p_searchable           IN       NUMBER,
      p_state_filter         IN       NUMBER,
      p_username             IN       VARCHAR2,
      cur                    OUT      refcur
   );
    PROCEDURE getDividedRequestsByYear (
    p_owner    IN       VARCHAR2,
    p_start_date IN     DATE,
    p_end_date IN       DATE,
    cur OUT refcur
    );
    
    
    PROCEDURE getlawyersforbranchmatris(cur OUT refcur);

    PROCEDURE getExcelReportResults (
    p_create_date_start    IN       DATE,
    p_create_date_end      IN       DATE,
    p_solution_date_start  IN       DATE,
    p_solution_date_end    IN       DATE,
    p_advice_types         IN       VARCHAR2,
    p_lawyers              IN       VARCHAR2,
    cur OUT refcur
    );
   
END LEGALADVICE_WS_UTILS;
/

