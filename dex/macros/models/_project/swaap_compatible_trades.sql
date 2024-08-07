{% macro swaap_v2_compatible_trades(
    blockchain = null,
    project = null,
    version = null
    )
%}

WITH dexs AS
(
    SELECT
        t.evt_block_number AS block_number
        , t.evt_block_time AS block_time
        , CAST(null AS VARBINARY) AS taker
        , t.contract_address AS maker
        , CASE WHEN amountIn < INT256 '0' THEN abs(amountIn) ELSE abs(amountOut) END AS token_bought_amount_raw -- when amountIn is negative it means trader_a is buying tokenIn from the pool
        , CASE WHEN amountIn < INT256 '0' THEN abs(amountOut) ELSE abs(amountIn) END AS token_sold_amount_raw
        , CASE WHEN amountIn < INT256 '0' THEN t.tokenIn ELSE t.tokenOut END AS token_bought_address
        , CASE WHEN amountIn < INT256 '0' THEN t.tokenOut ELSE t.tokenIn END AS token_sold_address
        , t.contract_address AS project_contract_address
        , t.evt_tx_hash AS tx_hash
        , t.evt_index AS evt_index
    FROM {{ source(project ~ '_v' ~ version ~ '_' ~ blockchain, 'Vault_evt_Swap' )}} t
    {% if is_incremental() %}
    WHERE
        {{ incremental_predicate('t.evt_block_time') }}
    {% endif %}
)

SELECT
    '{{ blockchain }}' AS blockchain
    , '{{ project }}' AS project
    , '{{ version }}' AS version
    , CAST(date_trunc('month', dexs.block_time) AS date) AS block_month
    , CAST(date_trunc('day', dexs.block_time) AS date) AS block_date
    , dexs.block_time
    , dexs.block_number
    , dexs.token_bought_amount_raw
    , dexs.token_sold_amount_raw
    , dexs.token_bought_address
    , dexs.token_sold_address
    , dexs.taker
    , dexs.maker
    , dexs.project_contract_address
    , dexs.tx_hash
    , dexs.evt_index
FROM
    dexs

{% endmacro %}
