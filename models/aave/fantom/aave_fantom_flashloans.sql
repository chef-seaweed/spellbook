{{
  config(
    schema = 'aave_fantom',
    alias = 'flashloans',
    materialized = 'view',
    post_hook = '{{ expose_spells(\'["fantom"]\',
                                    "project",
                                    "aave",
                                    \'["hildobby", "tomfutago"]\') }}'
  )
}}

select
  blockchain,
  project,
  version,
  recipient,
  amount,
  amount_usd,
  fee,
  symbol as currency_symbol,
  token_address as currency_contract,
  project_contract_address as contract_address,
  block_month,
  block_time,
  block_number,
  tx_hash,
  evt_index
from {{ ref('lending_flashloans') }}
where blockchain = 'fantom'
  and project = 'aave'
