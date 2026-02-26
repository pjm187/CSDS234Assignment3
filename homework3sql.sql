DROP TABLE IF EXISTS NurseNote; 
DROP TABLE IF EXISTS NurseNoteVec;

-- a
CREATE TABLE NurseNote(
	patient_id VARCHAR(50),
	address TEXT,
	note_text TEXT,
	visit_date DATE
);

INSERT INTO NurseNote(patient_id, address, note_text, visit_date) VALUES
('101', 'Cleveland, OH', 'child anxious after vaccination', '2025-02-12'),
('102', 'Akron, OH', 'persistent cough no fever', '2025-03-18'),
('103', 'Columbus, OH', 'vaccination follow-up mild fever', '2025-03-20');

SELECT * FROM NurseNote ORDER BY visit_date;

-- b

CREATE TABLE NurseNoteVec(
patient_id VARCHAR(50), 
v1 DOUBLE PRECISION, -- TF-IDF for "vaccinations"
v2 DOUBLE PRECISION, -- TF-IDF for "anxious"
v3 DOUBLE PRECISION -- TF-IDF for "cough"
);

INSERT INTO NurseNoteVec(patient_id, v1, v2, v3) VALUES
('101', 0.1761, 0.4771, 0),
('102', 0, 0, 0.4771),
('103', 0.1761, 0, 0);

SELECT * FROM NurseNoteVec;

-- c
WITH query_vec AS (
    SELECT 
        CAST(0.1761 AS DOUBLE PRECISION) AS q1, 
        CAST(0.4771 AS DOUBLE PRECISION) AS q2, 
        CAST(0.0 AS DOUBLE PRECISION) AS q3
)
SELECT n.patient_id, 
    -- The Dot Product / (Magnitude of Note * Magnitude of Query)
    (n.v1*q.q1 + n.v2*q.q2 + n.v3*q.q3) / 
    (sqrt(n.v1*n.v1 + n.v2*n.v2 + n.v3*n.v3) * sqrt(q.q1*q.q1 + q.q2*q.q2 + q.q3*q.q3)) 
    AS cosine_sim
FROM NurseNoteVec n, query_vec q
ORDER BY cosine_sim DESC
LIMIT 2;


-- d

SELECT xmlelement(
	NAME patient,
	xmlattributes(patient_id AS id),
	xmlelement(NAME address, address),
	xmlelement(
		NAME visits,
		xmlelement(
			NAME visit,
			xmlattributes(visit_date AS date),
			xmlelement(NAME note, note_text)
		)
	)
) AS patient_xml
FROM NurseNote
WHERE patient_id = '101';

