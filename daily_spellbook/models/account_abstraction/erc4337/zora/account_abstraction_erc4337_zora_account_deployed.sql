{{ config(
    alias = 'account_deployed',
    schema = 'account_abstraction_erc4337_zora',
    partition_by = ['block_month'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['userop_hash', 'tx_hash'],
    post_hook='{{ expose_spells(\'["zora"]\',
                                    "project",
                                    "erc4337",
                                    \'["0xbitfly", "peterrliem","intensodefi"]\') }}'
)}}


{% set erc4337_zora_models = [
    ref('account_abstraction_erc4337_zora_v0_6_account_deployed')
    , ref('account_abstraction_erc4337_zora_v0_7_account_deployed')
] %}

SELECT
          blockchain
        , version
        , block_time
        , block_month
        , userop_hash
        , entrypoint_contract
        , tx_hash
        , sender
        , paymaster
        , factory
FROM (
    {% for erc4337_model in erc4337_zora_models %}
    SELECT
          blockchain
        , version
        , block_time
        , block_month
        , userop_hash
        , entrypoint_contract
        , tx_hash
        , sender
        , paymaster
        , factory
    FROM {{ erc4337_model }}

    {% if is_incremental() %}
    WHERE {{ incremental_predicate('block_time') }}
    {% endif %}

    {% if not loop.last %}
    UNION ALL
    {% endif %}
    {% endfor %}
)