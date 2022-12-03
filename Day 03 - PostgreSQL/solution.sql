WITH backpacks AS (
    SELECT
        a.nr AS id,
        a.elem AS contents
    FROM
        UNNEST(string_to_array(pg_read_file('./input.txt'), E'\r\n')) WITH ORDINALITY AS a(elem, nr)
),
common_items AS (
    SELECT
        backpacks.id,
        ARRAY(
            SELECT UNNEST(string_to_array(SUBSTRING(backpacks.contents FROM 0 FOR LENGTH(backpacks.contents) / 2 + 1 ), NULL))
            INTERSECT
            SELECT UNNEST(string_to_array(SUBSTRING(backpacks.contents FROM LENGTH(backpacks.contents) / 2 + 1 FOR LENGTH(backpacks.contents) ), NULL))
        )
        FROM backpacks 
),
common_groups AS (
    SELECT
        backpacks.id,
        ARRAY(
            SELECT UNNEST(string_to_array(backpacks.contents, NULL))
            INTERSECT
            SELECT UNNEST(string_to_array((SELECT contents FROM backpacks AS newbackpack WHERE newbackpack.id = backpacks.id + 1 ), NULL))
            INTERSECT
            SELECT UNNEST(string_to_array((SELECT contents FROM backpacks AS newbackpack  WHERE newbackpack.id = backpacks.id + 2 ), NULL))
        ) AS badge
        FROM
            backpacks
        WHERE
            backpacks.id % 3 = 1
)
SELECT
    SUM(( SELECT
        SUM(
            CASE
                WHEN LOWER(letter) = letter THEN ascii(letter) - 96
                ELSE ascii(letter) - (64 - 26)
            END
        ) AS priority 
        FROM
            UNNEST(common_items.ARRAY) AS letter
    )) AS solution1,
    DIV(
        SUM((
            SELECT
                SUM(
                    CASE
                        WHEN LOWER(letter) = letter THEN ascii(letter) - 96
                        ELSE ascii(letter) - (64 - 26)
                    END
                ) AS priority
            FROM UNNEST(common_groups.badge) AS letter
        )),
        3 -- Div by 3 due to duplication when using inner join
    ) AS solution2
FROM
    backpacks
    JOIN
        common_items
        ON backpacks.id = common_items.id 
    JOIN
        common_groups
        ON backpacks.id = common_groups.id + ((backpacks.id - 1) % 3);
