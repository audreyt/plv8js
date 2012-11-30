q = -> """
    '#{ "#it".replace /'/g "''" }'
"""
qq = -> """
    "#{ "#it".replace /"/g '""' }"
"""

walk = (model, meta) ->
    return [] unless meta?[model]
    for col, spec of meta[model]
        [compile(model, spec), col]

compile = (model, field) ->
    {$query, $from, $and, $} = field ? {}
    switch
    | $from? => """
        (SELECT COALESCE(ARRAY_TO_JSON(ARRAY_AGG(_)), '[]') FROM (SELECT * FROM #from-table
            WHERE #{ qq "_#model" } = #model-table."_id" AND #{
                switch
                | $query?                   => cond model, $query
                | _                         => true
            }
        ) AS _)
    """ where from-table = qq "#{$from}s", model-table = qq "#{model}s"
    | $? => cond model, $
    | _ => field
cond = (model, spec) -> switch typeof spec
    | \number => spec
    | \string => qq spec
    | \object =>
        # Implicit AND on all k,v
        [ test model, qq(k), v for k, v of spec ] * "AND"
    | _ => it

test = (model, key, expr) -> switch typeof expr
    | <[ number boolean ]> => "(#key = #expr)"
    | \string => "(#key = #{ q expr })"
    | \object => for op, ref of expr
        switch op
            | \$gt =>
                res = evaluate model, ref
                return "(#key > #res)"
            | \$ =>
                return "#key = #model-table.#{ qq ref }" where model-table = qq "#{model}s"
            | _ => throw "Unknown operator: #op"
    | \undefined => true

evaluate = (model, ref) -> switch typeof ref
    | <[ number boolean ]> => "#ref"
    | \string => q #ref
    | \object => for op, v of ref => switch op
        | \$ => "#model-table.#{ qq v }" where model-table = qq "#{model}s"
        | \$ago => "'now'::timestamptz - #{ q "#v ms" }::interval"
        | _ => continue

module.exports = exports = { walk, compile }
