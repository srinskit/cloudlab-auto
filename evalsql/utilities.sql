DROP TABLE runs;

CREATE TABLE
	runs (
		program TEXT,
		dataset TEXT,
		engine TEXT,
		workers INTEGER,
		status TEXT,
		runtime REAL,
		output TEXT,
		dlbench_runtime REAL,
		folder TEXT,
		UNIQUE (program, dataset, engine, workers, folder)
	);

SELECT
	COUNT(*)
FROM
	runs;

-- .mode csv;
-- .import data.csv runs;

SELECT
	COUNT(*)
FROM
	runs;

UPDATE runs
SET
	program = 'doop'
WHERE
	program IN ('batik', 'biojava', 'eclipse', 'xalan', 'zxing');