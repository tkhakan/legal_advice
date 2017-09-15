CREATE OR REPLACE PACKAGE BODY LEGALADVICE.legaladvice_ws_utils
AS
/******************************************************************************
   NAME:       LEGALADVICE_WS_UTILS
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/1/2009      GÜZIN GÖRGÜN       1. Created this package.
******************************************************************************/
   PROCEDURE insertlegaladvicemaster (
      p_created_by               IN       VARCHAR2 DEFAULT NULL,
      -- p_create_date        IN            DATE DEFAULT NULL,
      p_department_code          IN       VARCHAR2 DEFAULT NULL,   
      p_call_subject             IN       VARCHAR2 DEFAULT NULL,
      p_advice_type              IN       VARCHAR2 DEFAULT NULL,
      p_policy_type              IN       VARCHAR2 DEFAULT NULL,
      p_call_summary             IN       VARCHAR2 DEFAULT NULL,
      p_call_explanation         IN       VARCHAR2 DEFAULT NULL,
      p_state                    IN       VARCHAR2 DEFAULT NULL,
      p_state_date               IN       DATE DEFAULT NULL,
      p_stated_by                IN       VARCHAR2 DEFAULT NULL,
      p_solution_code            IN       VARCHAR2 DEFAULT NULL,
      p_solution_date            IN       DATE DEFAULT NULL,
      p_solution_explanation     IN       VARCHAR2 DEFAULT NULL,
      p_alternative_solution_r   IN       NUMBER DEFAULT NULL,
      p_lawyer_receive_date      IN       DATE DEFAULT NULL,
      p_call_no                  OUT      NUMBER
   )
   IS
     v_created_by                 VARCHAR2(30) :=  p_created_by;
      v_department_code            VARCHAR2(100):= p_department_code;
      v_call_subject               VARCHAR2(200):= p_call_subject;      
      v_advice_type                VARCHAR2(4):= p_advice_type; 
      v_policy_type                VARCHAR2(4):= p_policy_type;
      v_call_summary               VARCHAR2(4000):= p_call_summary;
      v_call_explanation           VARCHAR2(4000):= p_call_explanation;
      v_state                      VARCHAR2(2):= p_state;
      v_state_date                 DATE := p_state_date;
      v_stated_by                  VARCHAR2(30) := p_stated_by;
      v_solution_code              VARCHAR2(4) := p_solution_code;
      v_solution_date              DATE := p_solution_date;
      v_solution_explanation       VARCHAR2(2000) := p_solution_explanation;
      v_alternative_solution_r     NUMBER(1) := p_alternative_solution_r;
      v_lawyer_receive_date        DATE := p_lawyer_receive_date ;      
      v_call_no   NUMBER;
      v_date      DATE;
      
      
   BEGIN
      IF v_call_no IS NULL
      THEN
         SELECT legaladvice.la_call_no_seq.NEXTVAL
           INTO v_call_no
           FROM DUAL;
      ELSE
         v_call_no := p_call_no;
      END IF;

      IF v_lawyer_receive_date IS NOT NULL
      THEN
         v_date := SYSDATE;
      ELSE
         v_date := NULL;
      END IF;

      INSERT INTO legal_advice_master
                  (call_no, created_by, create_date,
                   call_department_code, call_subject, advice_type,
                   policy_type, call_summary, call_explanation,
                   state, state_date, stated_by, instance_id, searchable,
                   solution_code, solution_explanation, solution_date,
                   alternative_solution_requested, lawyer_receive_date
                  )
           VALUES (v_call_no, SUBSTR (v_created_by, 1, 30), SYSDATE,
                   v_department_code, v_call_subject, v_advice_type,
                   v_policy_type, v_call_summary, v_call_explanation,
                   v_state, v_state_date, v_stated_by, NULL, 0,
                   v_solution_code, v_solution_explanation, v_solution_date,
                   v_alternative_solution_r, v_date
                  );

        commit;
     p_call_no := v_call_no;
   EXCEPTION
   
   
    WHEN OTHERS
     THEN
     rollback;
     
--   EXCEPTION
--      WHEN OTHERS
--      THEN
--         p_return := 0;
   END;

/*PROCEDURE findLawyer (
    p_policy_claim_type IN Varchar2,
    p_department_code IN Varchar2,
    cur OUT refcur
   ) is
     v_result   refcur;
    begin
         OPEN v_result FOR
            select
                POLICY_CLAIM_TYPE, DEPARTMENT_CODE, LAWYER_USERID, LAWYER_FIRSTNAME, LAWYER_LASTNAME
                from legal_advice_categorization
                where (policy_claim_type = p_policy_claim_type
                or department_code = p_department_code) and rownum<2;

            cur := v_result;
     end;
  */
   PROCEDURE findlawyer (
      p_policy_claim_type   IN       VARCHAR2,
      p_department_code     IN       VARCHAR2,
      cur                   OUT      refcur
   )
   IS
      v_result    refcur;
        /*
      CURSOR curbranch
      IS
         SELECT a.TYPE policyclaimtype, NULL departmentcode,
                a.lawyer_userid lawyeruserid, b.NAME lawyerfirstname,
                b.surname lawyerlastname
           FROM legal_advice_responsibility a, legal_advice_lawyers b
          WHERE b.ID = a.lawyer_userid
            AND a.unit = 'POLCLMTYP'
            AND a.TYPE = p_policy_claim_type;

      recbranch   curbranch%ROWTYPE;

      CURSOR curdep
      IS
         SELECT NULL policyclaimtype, a.TYPE departmentcode,
                a.lawyer_userid lawyeruserid, b.NAME lawyerfirstname,
                b.surname lawyerlastname
           FROM legal_advice_responsibility a, legal_advice_lawyers b
          WHERE b.ID = a.lawyer_userid
            AND a.unit = 'DEPCODE'
            AND a.TYPE = p_department_code;

      recdep      curdep%ROWTYPE;
      */
   BEGIN
        OPEN v_result FOR
        SELECT a.TYPE policyclaimtype, NULL departmentcode,
               a.lawyer_userid lawyeruserid, b.NAME lawyerfirstname,
               b.surname lawyerlastname
          FROM legal_advice_responsibility a, legal_advice_lawyers b
         WHERE b.ID = a.lawyer_userid
           AND a.unit = 'POLCLMTYP'
           AND (b.VALIDITY_END_DATE IS NULL OR b.VALIDITY_END_DATE>sysdate)
           AND a.TYPE = p_policy_claim_type;

      /*
      OPEN curbranch;

      LOOP
         FETCH curbranch
          INTO recbranch;

         OPEN v_result FOR
            SELECT a.TYPE policyclaimtype, NULL departmentcode,
                   a.lawyer_userid lawyeruserid, b.NAME lawyerfirstname,
                   b.surname lawyerlastname
              FROM legal_advice_responsibility a, legal_advice_lawyers b
             WHERE b.ID = a.lawyer_userid
               AND a.unit = 'POLCLMTYP'
               AND a.TYPE = p_policy_claim_type;

         IF curbranch%ROWCOUNT = 0
         THEN
            BEGIN
               OPEN curdep;

               LOOP
                  FETCH curdep
                   INTO recdep;

                  OPEN v_result FOR
                     SELECT NULL policyclaimtype, a.TYPE departmentcode,
                            a.lawyer_userid lawyeruserid,
                            b.NAME lawyerfirstname, b.surname lawyerlastname
                       FROM legal_advice_responsibility a,
                            legal_advice_lawyers b
                      WHERE b.ID = a.lawyer_userid
                        AND a.unit = 'DEPCODE'
                        AND a.TYPE = p_department_code;

                  EXIT WHEN curdep%NOTFOUND;
               END LOOP;

               CLOSE curdep;
            END;
         END IF;

         EXIT WHEN curbranch%NOTFOUND;
      END LOOP;

      CLOSE curbranch;
        */
        
      cur := v_result;
   END;

   PROCEDURE getlegaladvicedetail (p_call_no NUMBER, cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT   call_no, order_no, created_by, create_date, owner, state,
                  state_date, stated_by, call_explanation, department,
                  alternative_solution_exp, judicial_results,
                  relevant_legislation
             FROM legal_advice_detail
            WHERE call_no = p_call_no
         ORDER BY order_no, create_date;

      cur := v_result;
   END;

   PROCEDURE getladvicemasterinfobyinstid (
      p_instance_id         VARCHAR2,
      cur             OUT   refcur
   )
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT call_no, created_by, create_date, call_department_code,
                call_subject, advice_type, policy_type, call_summary,
                call_explanation, state, state_date, stated_by, instance_id,
                searchable, solution_code, solution_explanation,
                solution_date, alternative_solution_requested,
                lawyer_receive_date,owner,elapsed_time
           FROM legal_advice_master
          WHERE instance_id LIKE p_instance_id;

      cur := v_result;
   END;

   PROCEDURE getladvicemasterinfobycallno (
      p_call_no   IN       VARCHAR2,
      cur         OUT      refcur
   )
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT call_no, created_by, create_date, call_department_code,
                call_subject, advice_type, policy_type, call_summary,
                call_explanation, state, state_date, stated_by, instance_id,
                searchable, solution_code, solution_explanation,
                solution_date, alternative_solution_requested,
                lawyer_receive_date,owner,recall_instance_id
           FROM legal_advice_master
          WHERE call_no = p_call_no;

      cur := v_result;
   END;

      PROCEDURE insertlegaladvicedetail (
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
   )
   IS
   BEGIN

      INSERT INTO legal_advice_detail
                  (call_no, order_no, created_by, create_date,
                   owner, state, state_date, stated_by,
                   call_explanation, department,
                   alternative_solution_exp, judicial_results,
                   relevant_legislation, state_duration
                  )
           VALUES (p_call_no, p_order_no, p_created_by, p_create_date,
                   p_owner, p_state, p_state_date, p_stated_by,
                   p_call_explanation, p_department,
                   p_alternative_solution_exp, p_judicial_results,
                   p_relevant_legislation, p_state_duration
                  );
    
         commit;
    
   EXCEPTION
   
   
    WHEN OTHERS
     THEN
     rollback;                  
   END;

   PROCEDURE getcallparameterlist (p_look_code IN VARCHAR2, cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT look_up_code, code, description
           FROM legal_advice_parameters
          WHERE look_up_code = 'LOOK';

      cur := v_result;
   END;

   PROCEDURE getdepartmantinfo (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT code, NAME
           FROM legal_advice_departments ORDER BY NAME;

      cur := v_result;
   END;

   PROCEDURE getdepresponsibility (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         /*
         select d.CODE,d.NAME,
           r.LAWYER_USERID,r.LAWYER_FIRSTNAME,r.LAWYER_LASTNAME from
           legal_advice_responsibility r,
           legal_advice_departments d
           where d.CODE = r.TYPE (+);
           */
         SELECT d.code, d.NAME, r.lawyer_userid, l.NAME lawyer_firstname,
                l.surname lawyer_lastname
           FROM legal_advice_responsibility r,
                legal_advice_departments d,
                legal_advice_lawyers l
          WHERE d.code = r.TYPE(+) AND l.ID(+) = r.lawyer_userid
          order by d.name;

      cur := v_result;
   END;

   PROCEDURE getbranchresponsibility (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         /*  select d.CODE,d.description,
           r.LAWYER_USERID,r.LAWYER_FIRSTNAME,r.LAWYER_LASTNAME from
           legal_advice_responsibility r,
           legal_advice_parameters d
           where look_up_code='POLCLMTYP' and
              d.CODE = r.TYPE (+);
              */
         SELECT d.code, d.description, r.lawyer_userid,
                l.NAME lawyer_firstname, l.surname lawyer_lastname
           FROM legal_advice_responsibility r,
                legal_advice_parameters d,
                legal_advice_lawyers l
          WHERE d.look_up_code = 'POLCLMTYP'
            AND d.code = r.TYPE(+)
            AND l.ID(+) = r.lawyer_userid
            order by d.DESCRIPTION;

      cur := v_result;
   END;

   PROCEDURE getlawyername (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT ID, NAME, surname, department_code
           FROM legal_advice_lawyers;

      cur := v_result;
   END;

   PROCEDURE getlawyercount (COUNT OUT NUMBER)
   IS
      v_result   NUMBER;
   BEGIN
      SELECT COUNT (*) lawyercount
        INTO v_result
        FROM legal_advice_lawyers;

      COUNT := v_result;
   END;

      PROCEDURE getcallparameterdetails (
      p_parameter_code   IN       VARCHAR2,
      p_code             IN       VARCHAR2,
      cur                OUT      refcur
   )
   IS
      v_result   refcur;
   BEGIN
       OPEN v_result FOR
         SELECT look_up_code, code, description
           FROM legal_advice_parameters
          WHERE look_up_code = p_parameter_code AND code = NVL (p_code, code);

      cur := v_result;
   END;

   PROCEDURE getlegaladvicequestions (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT   row_no, question, answer
             FROM legal_advice_faq
         ORDER BY row_no;

      cur := v_result;
   END;

   PROCEDURE updateladvicemasterbyinstid (
      p_call_no            NUMBER,
      p_instanceid         VARCHAR2,
      p_return       OUT   NUMBER
   )
   IS
   BEGIN
      UPDATE legal_advice_master
         SET instance_id = p_instanceid
       WHERE call_no = p_call_no;

      p_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;
   
   PROCEDURE updatelabyrecallinstid (
      p_call_no            NUMBER,
      p_instanceid         VARCHAR2,
      p_return       OUT   NUMBER
   )
   IS
   BEGIN
      UPDATE legal_advice_master
         SET recall_instance_id = p_instanceid
       WHERE call_no = p_call_no;

      p_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;

   PROCEDURE updatesearchflag (p_call_no NUMBER, p_searchable NUMBER)
   IS
   BEGIN
      UPDATE legal_advice_master
         SET searchable = p_searchable
       WHERE call_no = p_call_no;
   END;

--      COMMIT;
   PROCEDURE updatecallstate (
      p_call_no     IN       NUMBER,
      p_state       IN       VARCHAR2,
      p_stated_by   IN       VARCHAR2,
      p_return      OUT      NUMBER
   )
   IS
   BEGIN
      UPDATE legal_advice_master
         SET state = p_state,
             stated_by = p_stated_by,
             state_date = SYSDATE
       WHERE call_no = p_call_no;

      p_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;

   PROCEDURE getcategorization (
      p_policy_claim_type         VARCHAR2,
      p_department_code           VARCHAR2,
      cur                   OUT   refcur
   )
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      pwhere     VARCHAR2 (2500) := '';
   BEGIN
      sqlstr1 :=
            'SELECT POLICY_CLAIM_TYPE, DEPARTMENT_CODE, LAWYER_USERID , LAWYER_FIRSTNAME ,LAWYER_LASTNAME '
         || ' from legal_advice_categorization WHERE 1=1 ';

      IF p_policy_claim_type IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' AND  POLICY_CLAIM_TYPE   ='''
            || p_policy_claim_type
            || '''';
      END IF;

      IF p_department_code IS NOT NULL
      THEN
         pwhere :=
            pwhere || ' AND  DEPARTMENT_CODE   =''' || p_department_code
            || '''';
      END IF;

      sqlstr1 := sqlstr1 || pwhere;

      OPEN v_result FOR sqlstr1;

      cur := v_result;
   END;

   PROCEDURE insertcategorization (
      p_policy_claim_type   IN   VARCHAR2 DEFAULT NULL,
      p_department_code     IN   VARCHAR2 DEFAULT NULL,
      p_lawyer_userid       IN   VARCHAR2 DEFAULT NULL,
      p_lawyer_firstname    IN   VARCHAR2 DEFAULT NULL,
      p_lawyer_lastname     IN   VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      INSERT INTO legal_advice_categorization
                  (policy_claim_type,
                   department_code, lawyer_userid,
                   lawyer_firstname, lawyer_lastname
                  )
           VALUES (NVL (p_policy_claim_type, ''),
                   NVL (p_department_code, ''), p_lawyer_userid,
                   p_lawyer_firstname, p_lawyer_lastname
                  );
   END;

   PROCEDURE insertdepresponsibility (
      p_department_code   IN   VARCHAR2 DEFAULT NULL,
      p_lawyer_userid     IN   VARCHAR2 DEFAULT NULL
   --  p_lawyer_firstname   IN            VARCHAR2 DEFAULT NULL,
   --  p_lawyer_lastname    IN            VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      INSERT INTO legaladvice.legal_advice_responsibility
                  (unit, TYPE, lawyer_userid
                  )
           VALUES ('DEPCODE', p_department_code, p_lawyer_userid
                  );
   END;

   PROCEDURE insertbranchresponsibility (
      p_policy_claim_type   IN   VARCHAR2 DEFAULT NULL,
      p_lawyer_userid       IN   VARCHAR2 DEFAULT NULL
   --   p_lawyer_firstname   IN            VARCHAR2 DEFAULT NULL
   --   p_lawyer_lastname    IN            VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      INSERT INTO legaladvice.legal_advice_responsibility
                  (unit, TYPE, lawyer_userid
                  )
           VALUES ('POLCLMTYP', p_policy_claim_type, p_lawyer_userid
                  );
   END;

   PROCEDURE insertattachment (
      p_call_no           IN       NUMBER,
      p_order_no          IN       NUMBER,
      p_attachment_id     IN       NUMBER,
      p_created_by        IN       VARCHAR2,
      p_explanation       IN       VARCHAR2,
      p_department_code   IN       VARCHAR2,
      p_content_type      IN       VARCHAR2,
      --p_attachment IN BLOB,
      p_return            OUT      NUMBER
   )
   IS
   BEGIN
      INSERT INTO legal_advice_attachment
                  (call_no, order_no, attachment_id, created_by,
                   create_date, explanation, attachment, department,
                   content_type
                  )
           VALUES (p_call_no, p_order_no, p_attachment_id, p_created_by,
                   SYSDATE, p_explanation, EMPTY_BLOB (), p_department_code,
                   p_content_type
                  );

      p_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;

   PROCEDURE removeattachment (
      p_call_no         IN       NUMBER,
      p_order_no        IN       NUMBER,
      p_attachment_id   IN       NUMBER,
      p_return          OUT      NUMBER
   )
   IS
   BEGIN
    IF p_attachment_id = 0 THEN
      DELETE FROM legal_advice_attachment
            WHERE call_no = p_call_no
              AND order_no = p_order_no;
              
     ELSE
        DELETE FROM legal_advice_attachment
            WHERE call_no = p_call_no
              AND order_no = p_order_no
              AND attachment_id = p_attachment_id;
    END IF;
      p_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;

   PROCEDURE updatecategorization (
      p_policy_claim_type   IN       VARCHAR2 DEFAULT NULL,
      p_department_code     IN       VARCHAR2 DEFAULT NULL,
      p_lawyer_userid       IN       VARCHAR2 DEFAULT NULL,
      p_lawyer_firstname    IN       VARCHAR2 DEFAULT NULL,
      p_lawyer_lastname     IN       VARCHAR2 DEFAULT NULL,
      p_return              OUT      NUMBER
   )
   IS
   BEGIN
      UPDATE legal_advice_categorization
         SET lawyer_userid = NVL (p_lawyer_userid, ''),
             lawyer_firstname = NVL (p_lawyer_firstname, ''),
             lawyer_lastname = NVL (p_lawyer_lastname, '')
       WHERE department_code = p_department_code
         AND policy_claim_type = p_policy_claim_type;

      p_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;

   PROCEDURE assigndepresponsable (
      d_unit            IN       VARCHAR2 DEFAULT NULL,
      d_type            IN       VARCHAR2 DEFAULT NULL,
      d_lawyer_userid   IN       VARCHAR2 DEFAULT NULL,
      --   d_lawyer_firstname   IN    VARCHAR2 DEFAULT NULL,
      --   d_lawyer_lastname    IN    VARCHAR2 DEFAULT NULL,
      d_return          OUT      NUMBER
   )
   IS
      v_exists NUMBER;
   BEGIN
    
     SELECT count(lawyer_userid)
        INTO v_exists 
        FROM legal_advice_responsibility 
        WHERE UNIT = d_unit AND TYPE = d_type;
    
    IF v_exists <> 0 THEN
      UPDATE legal_advice_responsibility d
         SET d.lawyer_userid = NVL (d_lawyer_userid, '')
      WHERE  d.unit = d_unit AND d.TYPE = d_type;
    ELSE
        insertdepresponsibility(d_type, d_lawyer_userid);
    END IF;     
    
      d_return := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         d_return := 0;
   END;

   PROCEDURE assignbranchresponsable (
      p_unit            IN       VARCHAR2 DEFAULT NULL,
      p_type            IN       VARCHAR2 DEFAULT NULL,
      p_lawyer_userid   IN       VARCHAR2 DEFAULT NULL,
      p_return          OUT      NUMBER
   )
   IS
     v_exists NUMBER;
   BEGIN
     SELECT count(lawyer_userid)
        INTO v_exists 
        FROM legal_advice_responsibility 
        WHERE UNIT = p_unit AND TYPE = p_type;
    
    IF v_exists <> 0 THEN
      UPDATE legal_advice_responsibility b
         SET b.lawyer_userid = NVL (p_lawyer_userid, '')
      WHERE  b.unit = p_unit AND b.TYPE = p_type;
    
    ELSE
       insertbranchresponsibility(p_type, p_lawyer_userid);
       UPDATE legal_advice_responsibility b
       SET b.lawyer_userid = p_lawyer_userid
       WHERE  b.unit = p_unit AND b.TYPE = p_type;
       
    END IF;  
    p_return := 1;   
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   END;

   PROCEDURE getnextorderno (p_call_no IN NUMBER, p_order_no OUT NUMBER)
   IS
      v_order_no   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_order_no
        FROM legal_advice_detail
       WHERE call_no = p_call_no;

      p_order_no := v_order_no + 1;
   END;

   PROCEDURE getnextattachmentid (
      p_call_no         IN       NUMBER,
      p_order_no        IN       NUMBER,
      p_attachment_id   OUT      NUMBER
   )
   IS
      v_attachment_no   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_attachment_no
        FROM legal_advice_attachment
       WHERE call_no = p_call_no AND order_no = p_order_no;

      p_attachment_id := v_attachment_no + 1;
   END;

   PROCEDURE getattachmentids (
      p_call_no    IN       NUMBER,
      p_order_no   IN       NUMBER,
      cur          OUT      refcur
   )
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT attachment_id
           FROM legal_advice_attachment
          WHERE call_no = p_call_no AND order_no = p_order_no;

      cur := v_result;
   END;

   PROCEDURE getattachmentinfo (
      p_call_no    IN       NUMBER,
      p_order_no   IN       NUMBER,
      cur          OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr     VARCHAR2 (2500);
   BEGIN
      sqlstr :=
            ' select CALL_NO, ORDER_NO, ATTACHMENT_ID, CREATED_BY, CREATE_DATE, EXPLANATION, DEPARTMENT, CONTENT_TYPE'
         || ' from legal_advice_attachment '
         || ' where call_no = '
         || p_call_no;

      IF p_order_no != -1
      THEN
         sqlstr := sqlstr || ' and order_no = ' || p_order_no;
      END IF;

      OPEN v_result FOR sqlstr;

      cur := v_result;
   END;

   PROCEDURE updatelegaladvicemaster (
      p_call_no                  IN       NUMBER,
      p_call_subject             IN       VARCHAR2 DEFAULT NULL,
      p_call_summary             IN       VARCHAR2 DEFAULT NULL,
      p_call_explanation         IN       VARCHAR2 DEFAULT NULL,
      p_state                    IN       VARCHAR2 DEFAULT NULL,
      p_state_date               IN       DATE DEFAULT NULL,
      p_stated_by                IN       VARCHAR2 DEFAULT NULL,
      p_solution_code            IN       VARCHAR2 DEFAULT NULL,
      p_solution_date            IN       DATE DEFAULT NULL,
      p_solution_explanation     IN       VARCHAR2 DEFAULT NULL,
      p_alternative_solution_r   IN       NUMBER DEFAULT NULL,
      p_lawyer_receive_date      IN       DATE DEFAULT NULL,      
      p_owner             IN       VARCHAR2 DEFAULT NULL,
      p_elapsed_time         IN       VARCHAR2 DEFAULT NULL,
      p_policy_type          IN         VARCHAR2 DEFAULT NULL,
      p_advice_type          IN         VARCHAR2 DEFAULT NULL,
      p_searchable             IN       NUMBER DEFAULT NULL,
      p_solution_duration       IN       NUMBER DEFAULT NULL,
      p_result                   OUT      NUMBER
   )
   IS
      v_date            DATE;
      v_state_date      DATE;
      v_solution_date   DATE;
      v_solution_duration NUMBER;

      CURSOR cur (p_call_no NUMBER)
      IS
         SELECT call_no, created_by, create_date, call_department_code,
                call_subject, advice_type, policy_type, call_summary,
                call_explanation, state, state_date, stated_by, instance_id,
                searchable, solution_code, solution_explanation,
                solution_date, alternative_solution_requested,
                lawyer_receive_date,owner,elapsed_time, solution_duration
           FROM legal_advice_master
          WHERE call_no = p_call_no;

      rec               cur%ROWTYPE;
   BEGIN
      OPEN cur (p_call_no);

      FETCH cur
       INTO rec;

      CLOSE cur;

      IF p_lawyer_receive_date IS NOT NULL
         AND rec.lawyer_receive_date IS NULL
      THEN
         v_date := SYSDATE;
      ELSE
         v_date := rec.lawyer_receive_date;
      END IF;

      IF p_solution_date IS NOT NULL
      THEN
         v_solution_date := SYSDATE;
      ELSE
         v_solution_date := rec.solution_date;
      END IF;

      IF p_state_date IS NOT NULL
      THEN
         v_state_date := SYSDATE;
      ELSE
         v_state_date := rec.state_date;
      END IF;
      
      IF NVL(rec.solution_duration, 0) = 0
      THEN
        v_solution_duration := p_solution_duration;
      ELSE
        v_solution_duration := rec.solution_duration;
      END IF;

      UPDATE legal_advice_master
         SET call_subject = NVL (p_call_subject, rec.call_subject),
             call_summary = NVL (p_call_summary, rec.call_summary),
             call_explanation = NVL (p_call_explanation, rec.call_explanation),
             state = NVL (p_state, rec.state),
             state_date = NVL (v_state_date, rec.state_date),
             stated_by = NVL (p_stated_by, rec.stated_by),
             solution_code = NVL (p_solution_code, rec.solution_code),
             solution_date = NVL (v_solution_date, rec.solution_date),
             solution_explanation =
                        NVL (p_solution_explanation, rec.solution_explanation),
             alternative_solution_requested =
                NVL (p_alternative_solution_r,
                     rec.alternative_solution_requested
                    ),
             lawyer_receive_date = NVL (v_date, rec.lawyer_receive_date),
             owner = NVL (p_owner, rec.owner),
             elapsed_time = NVL (p_elapsed_time, rec.elapsed_time),
             searchable = NVL(p_searchable,rec.searchable),
             policy_type = NVL(p_policy_type,rec.policy_type),
             advice_type = NVL(p_advice_type,rec.advice_type),
             solution_duration = v_solution_duration
       WHERE call_no = p_call_no;

      p_result := 1;
      
      commit;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result := 0;
         rollback;
   END;


 PROCEDURE updatelamasterForProcess (
      p_call_no                  IN       NUMBER,
      p_owner                    IN       VARCHAR2 DEFAULT NULL,
      p_result                   OUT      NUMBER
   )
   IS
BEGIN  

      UPDATE legal_advice_master
         SET state = '04',
             state_date = sysdate,
             stated_by = 'Auto',
             lawyer_receive_date = sysdate,
             owner = p_owner
         WHERE call_no = p_call_no;

      p_result := 1;
      
      commit;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result := 0;
         rollback;
   END;
   PROCEDURE getdiffofsysandreceivetime (p_call_no IN NUMBER, cur OUT refcur)
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
        SELECT floor((sysdate-LAWYER_RECEIVE_DATE)*24*60*60) seconds,
                sysdate sdate,LAWYER_RECEIVE_DATE lawyerreceivedate  
          FROM LEGAL_ADVICE_MASTER 
         WHERE call_no = p_call_no;

      cur := v_result;
   END;

   PROCEDURE getdiffofstateandreceivetime (p_call_no IN NUMBER, cur OUT refcur)
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
        SELECT floor((STATE_DATE-LAWYER_RECEIVE_DATE)*24*60*60) seconds,
                STATE_DATE sdate,LAWYER_RECEIVE_DATE lawyerreceivedate  
          FROM LEGAL_ADVICE_MASTER 
         WHERE call_no = p_call_no;

      cur := v_result;
   END;

   PROCEDURE getfurtherinfotimes (p_call_no IN NUMBER, cur OUT refcur)
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
        SELECT CREATE_DATE createdate,STATE_DATE statedate, 
                CASE WHEN CREATE_DATE = STATE_DATE THEN floor((sysdate-CREATE_DATE)*24*60*60) 
                ELSE floor((STATE_DATE-CREATE_DATE)*24*60*60) END seconds  
          FROM LEGAL_ADVICE_DETAIL where (state = '07' ) and call_no =  p_call_no;

      cur := v_result;
   END;

   PROCEDURE getfutherinfosearchresult (p_owner IN VARCHAR2, cur OUT refcur)
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      sqlstr     VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
         SELECT  a.call_no callNo, a.advice_type adviceType, a.CALL_SUBJECT callSubject, a.CREATED_BY createdBy, 
                 a.CALL_DEPARTMENT_CODE departmentCode,  a.STATE state,
                 a.CREATE_DATE createdDate, a.LAWYER_RECEIVE_DATE receiveDate, a.STATE state, a.CALL_EXPLANATION callMasterExp, 
                 c.DESCRIPTION adviceTypeExp,d.DESCRIPTION stateExp, depts.NAME departmentName 
           FROM legal_advice_master a ,legal_advice_parameters c,legal_advice_parameters d, legal_advice_departments depts, legal_advice_detail detail 
          WHERE  c.LOOK_UP_CODE   = 'ADVTYP' 
            AND  c.CODE  (+)         = a.ADVICE_TYPE 
            AND  d.LOOK_UP_CODE   = 'STATE'
            AND  d.CODE  (+)         = a.STATE 
            AND  depts.CODE (+)= a.CALL_DEPARTMENT_CODE
            AND  a.CALL_NO  = detail.CALL_NO 
            AND  a.state = detail.state 
            AND  a.state='07' 
            AND  upper(detail.stated_by) like upper(p_owner) 
       ORDER BY 1 desc,2 desc,5 ;

      cur := v_result;
   END;

   PROCEDURE getcompletedsearchresult (p_stated_by IN VARCHAR2, cur OUT refcur)
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      sqlstr     VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
          SELECT a.call_no callNo,a.advice_type adviceType,a.CALL_SUBJECT callSubject, a.CREATED_BY createdBy, 
                 a.CALL_DEPARTMENT_CODE departmentCode, a.STATE state,  
                 a.CREATE_DATE createdDate, a.LAWYER_RECEIVE_DATE receiveDate ,a.STATE state, a.CALL_EXPLANATION callMasterExp, 
                 c.DESCRIPTION adviceTypeExp,d.DESCRIPTION stateExp, depts.NAME departmentName 
            FROM legal_advice_master a ,legal_advice_parameters c,legal_advice_parameters d, legal_advice_departments depts 
           WHERE  c.LOOK_UP_CODE   = 'ADVTYP'
             AND  c.CODE  (+)         = a.ADVICE_TYPE 
             AND  d.LOOK_UP_CODE   = 'STATE' 
             AND  d.CODE  (+)         = a.STATE 
             AND  depts.CODE (+)= a.CALL_DEPARTMENT_CODE
             AND  a.solution_code='02' 
             AND  upper(a.stated_by) like upper(p_stated_by)
       ORDER BY 1 desc,2 desc,5;

      cur := v_result;
   END;

   PROCEDURE getcompletedsearchresultforusr (
      p_created_by   IN       VARCHAR2,
      cur            OUT      refcur
   )
   IS

      CURSOR cur_islawyer
      IS
         SELECT 1 
           FROM legal_advice_lawyers b
          WHERE b.ID = p_created_by;

      v_result   refcur;
      v_islawyer NUMBER(1);

   BEGIN
      OPEN cur_islawyer;
      FETCH cur_islawyer INTO v_islawyer;
      CLOSE cur_islawyer;

      IF NVL(v_islawyer, 0) = 0
      THEN
        OPEN  v_result FOR 
            SELECT  a.call_no callNo,a.advice_type adviceType,a.CALL_SUBJECT callSubject, a.CREATED_BY createdBy, 
                    a.CALL_DEPARTMENT_CODE departmentCode,  a.STATE state, 
                    a.CREATE_DATE createdDate, a.LAWYER_RECEIVE_DATE receiveDate ,a.STATE state, a.CALL_EXPLANATION callMasterExp, 
                    c.DESCRIPTION adviceTypeExp,d.DESCRIPTION stateExp, depts.NAME departmentName,a.STATE_DATE sdate         
              FROM  legal_advice_master a ,legal_advice_parameters c,legal_advice_parameters d, legal_advice_departments depts 
             WHERE  c.LOOK_UP_CODE   = 'ADVTYP'
               AND  c.CODE  (+)         = a.ADVICE_TYPE 
               AND  d.LOOK_UP_CODE   = 'STATE'         
               AND  d.CODE  (+)         = a.STATE 
               AND  depts.CODE (+)= a.CALL_DEPARTMENT_CODE
               AND  a.solution_code='02' 
               AND  upper(a.created_by) like upper(p_created_by)
          ORDER BY 1 desc,2 desc,5;
      ELSE
        OPEN  v_result FOR 
            SELECT  a.call_no callNo,a.advice_type adviceType,a.CALL_SUBJECT callSubject, a.CREATED_BY createdBy, 
                    a.CALL_DEPARTMENT_CODE departmentCode,  a.STATE state, 
                    a.CREATE_DATE createdDate, a.LAWYER_RECEIVE_DATE receiveDate ,a.STATE state, a.CALL_EXPLANATION callMasterExp, 
                    c.DESCRIPTION adviceTypeExp,d.DESCRIPTION stateExp, depts.NAME departmentName,a.STATE_DATE sdate         
              FROM  legal_advice_master a ,legal_advice_parameters c,legal_advice_parameters d, legal_advice_departments depts 
             WHERE  c.LOOK_UP_CODE   = 'ADVTYP'
               AND  c.CODE  (+)         = a.ADVICE_TYPE 
               AND  d.LOOK_UP_CODE   = 'STATE'         
               AND  d.CODE  (+)         = a.STATE 
               AND  depts.CODE (+)= a.CALL_DEPARTMENT_CODE
               AND  a.solution_code='02' 
               AND  upper(a.owner) like upper(p_created_by)
          ORDER BY 1 desc,2 desc,5;
      END IF;

      cur := v_result;
   END;

   PROCEDURE getdetailedlegaladviceresult (
      p_call_no              IN       NUMBER,
      p_call_subject         IN       VARCHAR2,
      p_advice_type          IN       VARCHAR2,
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
   )
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      pwhere     VARCHAR2 (2500) := '';
   BEGIN
      sqlstr1 :=
            ' SELECT distinct  a.call_no callNo,a.advice_type adviceType,a.CALL_SUBJECT callSubject, a.CREATED_BY createdBy, '
         || ' a.CALL_DEPARTMENT_CODE departmentCode, '
         || ' a.CREATE_DATE createdDate, a.LAWYER_RECEIVE_DATE receiveDate ,a.STATE state, a.CALL_EXPLANATION callMasterExp,  a.STATE state, '
         || ' c.DESCRIPTION adviceTypeExp,d.DESCRIPTION stateExp, depts.NAME departmentName,a.OWNER owner ,  a.STATE_DATE sdate '
         || ' FROM legal_advice_master a ,legal_advice_parameters c,legal_advice_parameters d, legal_advice_departments depts, legal_advice_detail detail '
         || ' WHERE  c.LOOK_UP_CODE   = ''ADVTYP'' '
         || '  and   c.CODE  (+)         = a.ADVICE_TYPE '
         || '  and   d.LOOK_UP_CODE   = ''STATE'' '
         || '  and   d.CODE  (+)         = a.STATE '
         || '  and depts.CODE (+)= a.CALL_DEPARTMENT_CODE'
         || '  and a.CALL_NO  = detail.CALL_NO (+) ';

      IF p_call_no IS NOT NULL
      THEN
         --pwhere := pwhere || ' and first_name like ''' || p_first_name || '''';
         pwhere := pwhere || ' AND  a.call_no   =' || p_call_no;
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(a.CREATE_DATE) between  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') and to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')';
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(a.CREATE_DATE) >=  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_created_date_start IS NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(a.CREATE_DATE) <=  to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_call_subject IS NOT NULL
      THEN
         pwhere :=
            pwhere || ' and (lower(a.call_subject) like ''%' || p_call_subject || '%'' or lower(a.call_explanation) like ''%' || p_call_subject || '%'' or lower(a.call_summary) like ''%' || p_call_subject || '%'')';
      END IF;

      IF p_advice_type IS NOT NULL
      THEN
         pwhere :=
             pwhere || ' AND  a.advice_type    = ''' || p_advice_type || '''';
      END IF;

      IF p_state IS NOT NULL
      THEN
         pwhere := pwhere || ' AND  a.state   = ''' || p_state || '''';
      END IF;

      IF p_department_code IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' AND  a.call_department_code   = '''
            || p_department_code
            || '''';
      END IF;

      IF p_created_by IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and upper(a.created_by) like upper('''
            || p_created_by
            || ''')';
         NULL;
      END IF;

      IF p_lawyer IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and upper(a.owner) = UPPER('''
            || p_lawyer
            || ''')';
            
      END IF;

      IF p_searchable = 1
      THEN
         pwhere := pwhere || ' and ( a.searchable =  1 or a.created_by = ''' || p_username || ''') ';
      END IF;

        IF p_state_filter = 1
        THEN
        pwhere := pwhere || ' AND  a.STATE  IN (''07'',''04'',''05'',''06'',''11'') AND a.LAWYER_RECEIVE_DATE IS NOT NULL AND a.SOLUTION_CODE IS NULL ' ;
      END IF;
      
      IF p_state_filter = 2
        THEN
        pwhere := pwhere || '  AND a.LAWYER_RECEIVE_DATE IS NOT NULL  ' ;
      END IF;
      
      sqlstr1 := sqlstr1 || pwhere;

      --    sqlstr := sqlstr1 || ' order by 1 desc,2 desc,5 ';
      OPEN v_result FOR sqlstr1;
        
      INSERT INTO TMP_SQL ts ( ts.SQL_STR,ts.STATE_DATE  ) VALUES (sqlstr1,sysdate);
      
      cur := v_result;
   END;

   PROCEDURE getlawyers (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT ID, NAME, surname, lawyer_order, department_code,VALIDITY_START_DATE,VALIDITY_END_DATE
           FROM legal_advice_lawyers  order by NAME ASC, SURNAME ASC;

      cur := v_result;
   END;
   
   PROCEDURE getWeeksRequest (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         select call_no callNo,state_date sdate,lawyer_receive_date rdate from legal_advice_master 
         where lawyer_receive_date is not null and solution_code is not null  and CREATE_DATE > (sysdate - 8);

      cur := v_result;
   END;
  
   PROCEDURE getRequestedDepartment (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         select COUNT(lam.CALL_NO) total,INITCAP(lad.NAME) name from legal_advice_master lam,LEGAL_ADVICE_DEPARTMENTS lad 
         where lam.CALL_DEPARTMENT_CODE = lad.CODE  
         GROUP BY lad.NAME ORDER BY count(lam.Call_no) DESC;

      cur := v_result;
   END;
   
   PROCEDURE gettotalandelapsedtime (
      p_owner    IN       VARCHAR2,
      cur          OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr     VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
            SELECT COUNT(call_no) total ,SUM(ELAPSED_TIME) elapsed 
              FROM LEGAL_ADVICE_MASTER 
             WHERE LAWYER_RECEIVE_DATE IS NOT NULL 
                AND SOLUTION_CODE IS not null 
                AND lower(owner) = lower(NVL(p_owner, owner));

      cur := v_result;
   END;
   
   PROCEDURE getStartedRequestAmount (
      cur          OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr     VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
          SELECT COUNT(call_no) total  
            FROM LEGAL_ADVICE_MASTER 
           WHERE LAWYER_RECEIVE_DATE IS NOT NULL 
                AND SOLUTION_CODE IS NULL;      

      cur := v_result;
   END;
   
    PROCEDURE getDividedRequests (
    p_owner    IN       VARCHAR2,
    cur OUT refcur
    )
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT l.NAME || ' ' || l.SURNAME name  
        ,(SELECT COUNT(call_no) from LEGAL_ADVICE_MASTER where lower(OWNER) = l.ID and   LAWYER_RECEIVE_DATE IS NOT NULL and SOLUTION_CODE IS not null
        and ELAPSED_TIME<24  ) "0" 
        ,(SELECT COUNT(call_no) from LEGAL_ADVICE_MASTER where lower(OWNER) = l.ID and   LAWYER_RECEIVE_DATE IS NOT NULL and 
        SOLUTION_CODE IS not null and ELAPSED_TIME BETWEEN 24 AND 48) "24"
        ,(SELECT COUNT(call_no) from LEGAL_ADVICE_MASTER where lower(OWNER) = l.ID and   LAWYER_RECEIVE_DATE IS NOT NULL and 
        SOLUTION_CODE IS  not null and ELAPSED_TIME>48 )  "48"
        from LEGAL_ADVICE_LAWYERS l where l.ID = lower(p_owner) ORDER BY l.LAWYER_ORDER;

      cur := v_result;
   END;
   
   PROCEDURE getDepDependentRq (
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      cur                    OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      pwhere     VARCHAR2 (2500) := '';
   BEGIN
      sqlstr1 :=
            ' SELECT COUNT(m.CALL_NO) num,INITCAP(d.NAME) dname,d.CODE code  FROM LEGAL_ADVICE_MASTER m , LEGAL_ADVICE_DEPARTMENTS d '
         || ' WHERE d.CODE = m.CALL_DEPARTMENT_CODE and  m.LAWYER_RECEIVE_DATE IS NOT NULL  ';
      
     
      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) between  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') and to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')';
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) >=  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_created_date_start IS NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) <=  to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;
    
      
      sqlstr1 := sqlstr1 || pwhere;

      sqlstr1 := sqlstr1 || ' GROUP BY d.NAME,d.CODE  ORDER BY COUNT(m.CALL_NO) DESC';
      OPEN v_result FOR sqlstr1;

      cur := v_result;
   END;
   
    PROCEDURE getAdvDependentRq (
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      cur                    OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      pwhere     VARCHAR2 (2500) := '';
   BEGIN
      sqlstr1 :=
            ' SELECT COUNT(m.CALL_NO) num,d.DESCRIPTION dname ,d.CODE code FROM LEGAL_ADVICE_MASTER m , LEGAL_ADVICE_PARAMETERS d '
         || ' WHERE d.CODE = m.ADVICE_TYPE and  m.LAWYER_RECEIVE_DATE IS NOT NULL AND d.LOOK_UP_CODE = ''ADVTYP''  ';
      
     
      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) between  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') and to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')';
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) >=  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_created_date_start IS NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) <=  to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;
    
      
      sqlstr1 := sqlstr1 || pwhere;

      sqlstr1 := sqlstr1 || ' GROUP BY d.DESCRIPTION,d.CODE ORDER BY COUNT(m.CALL_NO) DESC';
      OPEN v_result FOR sqlstr1;

      cur := v_result;
   END;
   
   PROCEDURE getLawDependentRq (
      p_created_date_start   IN       DATE,
      p_created_date_end     IN       DATE,
      cur                    OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      pwhere     VARCHAR2 (2500) := '';
   BEGIN
      sqlstr1 :=
            ' SELECT COUNT(m.CALL_NO) num,m.created_by dname  FROM LEGAL_ADVICE_MASTER m '
         || ' WHERE  m.LAWYER_RECEIVE_DATE IS NOT NULL  ';
      
     
      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) between  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') and to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')';
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) >=  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_created_date_start IS NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(m.CREATE_DATE) <=  to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;
    
      
      sqlstr1 := sqlstr1 || pwhere;

      sqlstr1 := sqlstr1 || ' GROUP BY m.created_by  order by  COUNT(m.CALL_NO) DESC';
      OPEN v_result FOR sqlstr1;

      cur := v_result;
   END;
   
    PROCEDURE getexplanationbystate (p_call_no NUMBER,p_state VARCHAR2, cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT   call_no, order_no, created_by, create_date, owner, state,
                  state_date, stated_by, call_explanation, department,
                  alternative_solution_exp, judicial_results,
                  relevant_legislation
             FROM legal_advice_detail
            WHERE call_no = p_call_no AND STATE = p_state
         ORDER BY order_no DESC;

      cur := v_result;
   END;
   
  PROCEDURE updateDetailsLastStateDate (
      p_call_no                  IN       NUMBER,
      p_state                    IN       VARCHAR2 DEFAULT NULL,
      p_state_date               IN       DATE,
      p_result                   OUT      NUMBER
   )
   IS
    BEGIN  

     IF NVL(p_state, '07') <> '07' THEN -- EU 30012017 07 icin state_date update edildiginde gecen sure hesabýi sasiyor,bu nedenle exclude edildi. 

         UPDATE LEGAL_ADVICE_DETAIL  SET STATE_DATE = p_state_date
              where call_no = p_call_no  and state =p_state and 
              ORDER_NO = (SELECT MAX(lal.ORDER_NO) FROM LEGAL_ADVICE_DETAIL lal 
              where lal.call_no = p_call_no  and lal.state = p_state   );

          commit;
     
     END IF;

     p_result := 1;
      
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result := 0;
        
   END;
   
    PROCEDURE getInstanceIdFromRecall (
      p_recall   IN       VARCHAR2,
      cur         OUT      refcur
   )
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT INSTANCE_ID
           FROM legal_advice_master
          WHERE RECALL_INSTANCE_ID = p_recall;

      cur := v_result;
   END;
   
   
   PROCEDURE updatelawyer ( 
      p_lawyer_id    IN        VARCHAR2,
      p_validity_end_date   IN     DATE,
      p_return       OUT   NUMBER
    )
    
    IS
    BEGIN

        UPDATE legal_advice_lawyers SET VALIDITY_END_DATE = p_validity_end_date where ID = p_lawyer_id;
  
  
        p_return := 1;
   
   commit;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   
   

END;
    
   PROCEDURE insertlawyer (
      p_lawyer_id  IN            VARCHAR2 ,      
      p_lawyer_name      IN            VARCHAR2,
      p_lawyer_surname  IN            VARCHAR2 ,  
      p_lawyer_order  IN            INTEGER , --kullanilmiyor, butunluk bozulmasin diye silmedik  
      p_lawyer_validity_start_date  IN            DATE   
   )
    IS
        v_lawyer_order NUMBER;
    BEGIN
        
        SELECT MAX(LAWYER_ORDER)+1
          INTO v_lawyer_order
          FROM legal_advice_lawyers; 

        INSERT INTO legal_advice_lawyers (ID, NAME, SURNAME,LAWYER_ORDER, VALIDITY_START_DATE) 
        VALUES (p_lawyer_id, p_lawyer_name,p_lawyer_surname, v_lawyer_order, p_lawyer_validity_start_date);



    END;

    PROCEDURE updatesla (
      p_advice_type     IN       VARCHAR2,
      p_policy_type     IN       VARCHAR2,
      p_sla             IN       NUMBER,
      p_return         OUT       NUMBER
      
      )
      IS
    BEGIN

         UPDATE legal_advice_sla SET SLA = p_sla where ADVICE_TYPE=p_advice_type AND POLICY_TYPE=p_policy_type;
  
  
            p_return := 1;
   
   commit;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return := 0;
   
   

    END;


    PROCEDURE getslalist (
      p_advice_type     IN       VARCHAR2,
      p_policy_type     IN       VARCHAR2,
      cur                OUT      refcur
   )
   IS
      v_result   refcur;
   BEGIN
    
        OPEN v_result FOR
         SELECT   a.description,b.advice_type,b.policy_type,b.sla
           FROM legal_advice_parameters a,legal_advice_sla b 
          WHERE  A.CODE=B.policy_type ;
          
          cur := v_result;
   END;
   
  PROCEDURE getpolicy (
   p_advice_type   IN VARCHAR2,
   cur             OUT      refcur
   )
   
   IS
   
     v_result refcur;
   BEGIN
    
        OPEN v_result FOR
         SELECT ( select  c.code from  legal_advice_parameters c where LOOK_UP_CODE='POLCLMTYP' and C.CODE in ( s.POLICY_TYPE)) code,   
         ( select  c.description from  legal_advice_parameters c where LOOK_UP_CODE='POLCLMTYP' and C.CODE in ( s.POLICY_TYPE)) DESCRIPTION,SLA,
         S.ADVICE_TYPE 
         FROM LEGAL_ADVICE_PARAMETERS P, LEGAL_ADVICE_SLA S
         WHERE P.CODE = S.ADVICE_TYPE AND P.LOOK_UP_CODE = 'ADVTYP'  AND S.ADVICE_TYPE =p_advice_type
         ORDER BY DESCRIPTION ASC;
          
          cur := v_result;
   END;
   
    PROCEDURE getlegaladviceparameters(
        p_look_up_code IN VARCHAR2,
        p_code         IN VARCHAR2,
        cur          OUT    refcur
   ) 
   IS
    v_result refcur;
    BEGIN
        OPEN v_result FOR
            SELECT LOOK_UP_CODE, CODE, DESCRIPTION 
            FROM LEGAL_ADVICE_PARAMETERS
            WHERE LOOK_UP_CODE = nvl(p_look_up_code, LOOK_UP_CODE)
                AND CODE = nvl(p_code, CODE)        
            ORDER BY LOOK_UP_CODE ASC, CODE ASC;
        
        cur := v_result;
        
   END;
   
   
    PROCEDURE insertsurvey (
      p_call_no          IN            NUMBER ,      
      p_answer1          IN            VARCHAR2,
      p_answer2          IN            VARCHAR2, 
      p_message          IN            VARCHAR2   
   )
      
      IS
    BEGIN

    INSERT INTO legal_advice_survey (CALL_NO, ANSWER1, ANSWER2,MESSAGE) 
    VALUES (p_call_no,p_answer1,p_answer2,p_message);



    END;


PROCEDURE getsurvey (
        p_callno IN NUMBER,
        cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT CALL_NO,ANSWER1,ANSWER2,MESSAGE,SURVEY_DATE
           FROM legal_advice_survey WHERE  CALL_NO = p_callno;  

      cur := v_result;
   END;  
   
   PROCEDURE gettotalandelapsedtimebyyear(
      p_year     IN       NUMBER,
      p_owner    IN       VARCHAR2,
      cur        OUT      refcur
   )
   IS 
   
      v_result   refcur;
      sqlstr     VARCHAR2 (2500);   
      
   BEGIN

      OPEN v_result FOR 
            SELECT COUNT(call_no) total ,SUM(ELAPSED_TIME) elapsed 
              FROM LEGAL_ADVICE_MASTER 
             WHERE LAWYER_RECEIVE_DATE IS NOT NULL 
                AND SOLUTION_CODE IS not null 
                AND EXTRACT(YEAR FROM LAWYER_RECEIVE_DATE) = p_year
                AND lower(owner) = lower(NVL(p_owner, owner));

      cur := v_result;
   END;
   
   
   
   PROCEDURE getStartedRequestAmountByYear (
      p_year       IN       NUMBER,
      cur          OUT      refcur
   )
   IS
      v_result   refcur;
      sqlstr     VARCHAR2 (2500);
   BEGIN

      OPEN v_result FOR 
           SELECT COUNT(call_no) total  
             FROM LEGAL_ADVICE_MASTER 
            WHERE LAWYER_RECEIVE_DATE IS NOT NULL 
                AND SOLUTION_CODE IS  null  
                AND EXTRACT(YEAR FROM LAWYER_RECEIVE_DATE) = p_year ;

      cur := v_result;
   END;
   
   
   PROCEDURE getdetailedlegaladviceresult2 (
      p_call_no              IN       NUMBER,
      p_call_subject         IN       VARCHAR2,
      p_advice_type          IN       VARCHAR2,
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
   )
   IS
      v_result   refcur;
      sqlstr1    VARCHAR2 (2500);
      pwhere     VARCHAR2 (2500) := '';
   BEGIN
      sqlstr1 :=
            ' SELECT distinct  a.call_no callNo,a.advice_type adviceType,a.CALL_SUBJECT callSubject, a.CREATED_BY createdBy, '
         || ' a.CALL_DEPARTMENT_CODE departmentCode, '
         || ' a.CREATE_DATE createdDate, a.LAWYER_RECEIVE_DATE receiveDate ,a.STATE state, a.CALL_EXPLANATION callMasterExp,  a.STATE state, '
         || ' c.DESCRIPTION adviceTypeExp,d.DESCRIPTION stateExp, depts.NAME departmentName,a.OWNER owner ,  a.STATE_DATE sdate '
         || ' FROM legal_advice_master a ,legal_advice_parameters c,legal_advice_parameters d, legal_advice_departments depts, legal_advice_detail detail '
         || ' WHERE  c.LOOK_UP_CODE   = ''ADVTYP'' '
         || '  and   c.CODE  (+)         = a.ADVICE_TYPE '
         || '  and   d.LOOK_UP_CODE   = ''STATE'' '
         || '  and   d.CODE  (+)         = a.STATE '
         || '  and depts.CODE (+)= a.CALL_DEPARTMENT_CODE'
         || '  and a.CALL_NO  = detail.CALL_NO (+) and EXTRACT(YEAR FROM LAWYER_RECEIVE_DATE) = ' || p_created_date_start ;

      IF p_call_no IS NOT NULL
      THEN
         --pwhere := pwhere || ' and first_name like ''' || p_first_name || '''';
         pwhere := pwhere || ' AND  a.call_no   =' || p_call_no;
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(a.CREATE_DATE) between  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') and to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')';
      END IF;

      IF p_created_date_start IS NOT NULL AND p_created_date_end IS NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(a.CREATE_DATE) >=  to_date('''
            || TO_CHAR (p_created_date_start, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_created_date_start IS NULL AND p_created_date_end IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and trunc(a.CREATE_DATE) <=  to_date('''
            || TO_CHAR (p_created_date_end, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') ';
      END IF;

      IF p_call_subject IS NOT NULL
      THEN
         pwhere :=
            pwhere || ' and (lower(a.call_subject) like ''%' || p_call_subject || '%'' or lower(a.call_explanation) like ''%' || p_call_subject || '%'' or lower(a.call_summary) like ''%' || p_call_subject || '%'')';
      END IF;

      IF p_advice_type IS NOT NULL
      THEN
         pwhere :=
             pwhere || ' AND  a.advice_type    = ''' || p_advice_type || '''';
      END IF;

      IF p_state IS NOT NULL
      THEN
         pwhere := pwhere || ' AND  a.state   = ''' || p_state || '''';
      END IF;

      IF p_department_code IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' AND  a.call_department_code   = '''
            || p_department_code
            || '''';
      END IF;

      IF p_created_by IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and upper(a.created_by) like upper('''
            || p_created_by
            || ''')';
         NULL;
      END IF;

      IF p_lawyer IS NOT NULL
      THEN
         pwhere :=
               pwhere
            || ' and UPPER(a.owner) = UPPER('''
            || p_lawyer
            || ''')';
            
      END IF;

      IF p_searchable = 1
      THEN
         pwhere := pwhere || ' and ( a.searchable =  1 or a.created_by = ''' || p_username || ''') ';
      END IF;

        IF p_state_filter = 1
        THEN
        pwhere := pwhere || ' AND  a.STATE  IN (''07'',''04'',''05'',''06'',''11'') AND a.LAWYER_RECEIVE_DATE IS NOT NULL AND a.SOLUTION_CODE IS NULL ' ;
      END IF;
      
      IF p_state_filter = 2
        THEN
        pwhere := pwhere || '  AND a.LAWYER_RECEIVE_DATE IS NOT NULL  ' ;
      END IF;
      
      sqlstr1 := sqlstr1 || pwhere;

      --    sqlstr := sqlstr1 || ' order by 1 desc,2 desc,5 ';
      OPEN v_result FOR sqlstr1;
        
      INSERT INTO TMP_SQL ts ( ts.SQL_STR,ts.STATE_DATE  ) VALUES (sqlstr1,sysdate);
      
      cur := v_result;
   END;
    PROCEDURE getDividedRequestsByYear (
    p_owner    IN       VARCHAR2,
    p_start_date IN     DATE,
    p_end_date IN       DATE,
    cur OUT refcur
    )
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT l.NAME || ' ' || l.SURNAME name  
        ,(SELECT COUNT(call_no) from LEGAL_ADVICE_MASTER where lower(OWNER) = l.ID and   LAWYER_RECEIVE_DATE IS NOT NULL and SOLUTION_CODE IS not null
        and ELAPSED_TIME<24 AND LAWYER_RECEIVE_DATE BETWEEN p_start_date and p_end_date ) "0" 
        ,(SELECT COUNT(call_no) from LEGAL_ADVICE_MASTER where lower(OWNER) = l.ID and   LAWYER_RECEIVE_DATE IS NOT NULL and 
        SOLUTION_CODE IS not null and ELAPSED_TIME BETWEEN 24 AND 48  AND LAWYER_RECEIVE_DATE BETWEEN p_start_date and p_end_date) "24" 
        ,(SELECT COUNT(call_no) from LEGAL_ADVICE_MASTER where lower(OWNER) = l.ID and   LAWYER_RECEIVE_DATE IS NOT NULL and 
        SOLUTION_CODE IS  not null and ELAPSED_TIME>48  AND LAWYER_RECEIVE_DATE BETWEEN p_start_date and p_end_date)  "48" 
        from LEGAL_ADVICE_LAWYERS l where l.ID = lower(p_owner) ORDER BY l.LAWYER_ORDER;

      cur := v_result;
   END;
   
   
   PROCEDURE getlawyersforbranchmatris (cur OUT refcur)
   IS
      v_result   refcur;
   BEGIN
      OPEN v_result FOR
         SELECT ID, NAME, surname, lawyer_order, department_code,VALIDITY_START_DATE,VALIDITY_END_DATE
           FROM legal_advice_lawyers WHERE VALIDITY_END_DATE IS NULL OR VALIDITY_END_DATE>sysdate order by LAWYER_ORDER;

      cur := v_result;
   END;

    PROCEDURE getExcelReportResults (
    p_create_date_start    IN       DATE,
    p_create_date_end      IN       DATE,
    p_solution_date_start  IN       DATE,
    p_solution_date_end    IN       DATE,
    p_advice_types         IN       VARCHAR2,
    p_lawyers              IN       VARCHAR2,
    cur OUT refcur
    )
    IS 
        v_result refcur;
        v_sql VARCHAR2(4000);
    BEGIN

        v_sql :=
                'SELECT m.CALL_NO, m.CREATED_BY, m.CREATE_DATE, m.CALL_DEPARTMENT_CODE, m.CALL_SUBJECT, m.ADVICE_TYPE, m.POLICY_TYPE, m.CALL_SUMMARY, m.CALL_EXPLANATION, '
                || 'm.STATE, m.STATE_DATE, m.STATED_BY, m.INSTANCE_ID, m.SEARCHABLE, m.SOLUTION_CODE, m.SOLUTION_DATE, '
                || 'nvl(M.SOLUTION_EXPLANATION, (SELECT CALL_EXPLANATION FROM LEGAL_ADVICE_DETAIL L WHERE L.CALL_NO = m.CALL_NO AND L.STATE = ''08''
                   and STATE_DATE = (SELECT max(STATE_DATE) FROM LEGAL_ADVICE_DETAIL L WHERE L.CALL_NO = m.CALL_NO AND L.STATE = ''08''))) SOLUTION_EXPLANATION, '
                || 'm.ALTERNATIVE_SOLUTION_REQUESTED, m.LAWYER_RECEIVE_DATE, m.OWNER, m.ELAPSED_TIME, m.RECALL_INSTANCE_ID, m.SOLUTION_DURATION, '
                || 's.ANSWER1,s.ANSWER2,s.MESSAGE, s.SURVEY_DATE ' 
                || ' from legal_advice_master m, legal_advice_survey s WHERE 1=1 AND m.CALL_NO = S.CALL_NO (+)';

      IF p_create_date_start IS NOT NULL AND p_create_date_end IS NOT NULL
      THEN
         v_sql := v_sql 
            || ' AND  m.CREATE_DATE  BETWEEN TO_DATE(''' || to_char(p_create_date_start, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') '
            || ' AND TO_DATE(''' || to_char(p_create_date_end, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')';
      END IF;

      IF p_solution_date_start IS NOT NULL AND p_solution_date_end IS NOT NULL
      THEN
         v_sql := v_sql 
            || ' AND  m.SOLUTION_DATE  BETWEEN TO_DATE(''' || to_char(p_solution_date_start, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') '
            || ' AND TO_DATE(''' || to_char(p_solution_date_end, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')';
      END IF;

      IF p_advice_types IS NOT NULL
      THEN
         v_sql := v_sql || ' AND m.ADVICE_TYPE IN (' || p_advice_types || ') ';
      END IF;
      
      IF p_lawyers IS NOT NULL
      THEN
         v_sql := v_sql || ' AND LOWER(m.OWNER) IN (' || p_lawyers || ') ';
      END IF;

      v_sql := v_sql || ' ORDER BY m.CREATE_DATE DESC ';

        
        INSERT INTO TMP_SQL VALUES (SYSDATE, v_sql);
        commit;

      OPEN v_result FOR v_sql;

        cur := v_result;
    END;

   
   END LEGALADVICE_WS_UTILS;
/

