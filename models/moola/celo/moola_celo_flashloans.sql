{{
  config(
    schema = 'moola_celo',
    alias = 'flashloans',
    materialized = 'view',
    post_hook = '{{ expose_spells(\'["celo"]\',
                                    "project",
                                    "moola",
                                    \'["tomfutago"]\') }}'
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
where blockchain = 'celo'
  and project = 'moola'
