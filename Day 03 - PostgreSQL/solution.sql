WITH nest AS (
    SELECT
        a.elem,
        a.nr 
    FROM
        UNNEST( string_to_array( pg_read_file('./input.txt'), E'\r\n' ) ) WITH ORDINALITY AS a(elem, nr) 
),
common AS (
    SELECT
        nest.nr,
        ARRAY( 
            SELECT UNNEST( string_to_array( SUBSTRING( nest.elem FROM 0 FOR LENGTH(nest.elem) / 2 + 1 ), NULL ) )
            INTERSECT
            SELECT UNNEST( string_to_array( SUBSTRING( nest.elem FROM LENGTH(nest.elem) / 2 + 1 FOR LENGTH(nest.elem) ), NULL ) ) 
        )
        FROM nest 
),
common_groups AS (
    SELECT
        nest.nr,
        ARRAY( 
            SELECT UNNEST( string_to_array(nest.elem, NULL) ) 
            INTERSECT
            SELECT UNNEST( string_to_array( ( SELECT elem FROM nest AS leadpack WHERE leadpack.nr = nest.nr + 1 ), NULL ) ) 
            INTERSECT
            SELECT UNNEST( string_to_array( ( SELECT elem FROM nest AS leadpack  WHERE leadpack.nr = nest.nr + 2 ), NULL ) ) 
        ) AS badge 
        FROM
            nest 
        WHERE
            nest.nr % 3 = 1 
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
            UNNEST(common_letters.ARRAY) AS letter
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
    nest
    JOIN
        common AS common_letters 
        ON nest.nr = common_letters.nr 
    JOIN
        common_groups 
        ON nest.nr = common_groups.nr + ( (nest.nr - 1) % 3 );
