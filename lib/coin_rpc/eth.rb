class CoinRPC::ETH < CoinRPC::BaseRPC
  def currency
    Currency.find_by_code('eth')
  end

  def protocol_version
    send_post_request('eth_protocolVersion')
  end

  def syncing
    send_post_request('eth_syncing')
  end

  def coinbase
    send_post_request('eth_coinbase')
  end

  def mining
    send_post_request('eth_mining')
  end

  def hashrate
    send_post_request('eth_hashrate')
  end

  def gas_price
    send_post_request('eth_gasPrice')
  end

  def accounts
    send_post_request('eth_accounts')
  end

  def block_number
    send_post_request('eth_blockNumber')
  end

  def get_balance(addr, block_num_data)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_blockNumber', addr, quant_or_tag)
  end

  def get_storage_at(addr, posit, block_num_data)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getStorageAt', addr, posit, block_num_data)
  end

  def get_transaction_count(addr, block_num_data)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getTransactionCount', addr, block_num_data)
  end

  def get_block_transaction_count_by_hash(h)
    send_post_request('eth_getBlockTransactionCountByHash', h)
  end

  def get_block_transaction_count_by_number(block_num_data)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getBlockTransactionCountByNumber', block_num_data)
  end

  def get_uncle_count_by_block_hash(h)
    send_post_request('eth_getUncleCountByBlockHash', h)
  end

  def get_uncle_count_by_block_number(block_num_data)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getUncleCountByBlockNumber', block_num_data)
  end

  def get_code(addr, block_num_data)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getCode', addr, quant_or_tag)
  end

  def sign(addr, msg)
    send_post_request('eth_sign', addr, quant_or_tag)
  end

  def send_transaction(from:, to:, gas: 90000, gas_price: nil, value: nil, data:, nonce: nil)
    obj_par = {from: from, to: to, gas: gas, data: data}
    obj_par[:gasPrice] = gas_price if gas_price
    obj_par[:value] = value if value != nil
    obj_par[:nonce] = nonce if nonce != nil

    send_post_request('eth_sendTransaction', obj_par)
  end

  def send_raw_transaction(data)
    send_post_request('eth_sendRawTransaction', data)
  end

  def call(from: nil, to:, gas: nil, gas_price: nil, value: nil, data: nil, block_num_data:)
    verify_block_number_or_tag!(block_num_data)

    obj_par = {to: to, gas: gas, data: data}
    obj_par[:from] = from if from
    obj_par[:gas] = gas if gas
    obj_par[:gasPrice] = gas_price if gas_price
    obj_par[:value] = value if value != nil
    obj_par[:data] = data if data != nil

    send_post_request('eth_call', obj_par, block_num_data)
  end

  def estimate_gas(n)
    send_post_request('eth_estimateGas', n)
  end

  def get_block_by_hash(h, ret_val_as_objs)
    send_post_request('eth_getBlockByHash', h, ret_val_as_objs)
  end

  def get_block_by_number(block_num_data, ret_val_as_objs)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getBlockByNumber', block_num_data, ret_val_as_objs)
  end

  def get_transaction_by_hash(h)
    send_post_request('eth_getTransactionByHash', h)
  end

  def get_transaction_by_block_hash_and_index(block_num_data, idx)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getTransactionByBlockNumberAndIndex', block_num_data, idx)
  end

  def get_transaction_by_block_number_and_index(block_num_data, idx)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getTransactionByBlockNumberAndIndex', block_num_data, idx)
  end

  def get_transaction_receipt(h)
    send_post_request('eth_getTransactionReceipt', h)
  end

  def get_uncle_by_block_hash_and_index(block_num_data, idx)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getUncleByBlockHashAndIndex', block_num_data, idx)
  end

  def get_uncle_by_block_number_and_index(block_num_data, idx)
    verify_block_number_or_tag!(block_num_data)
    send_post_request('eth_getUncleByBlockNumberAndIndex', block_num_data, idx)
  end

  def get_compilers
    send_post_request('eth_getCompilers')
  end

  def compile_solidity(src_code)
    send_post_request('eth_compileSolidity', src_code)
  end

  def compile_lll(src_code)
    send_post_request('eth_compileLLL', src_code)
  end

  def compile_serpent(src_code)
    send_post_request('eth_compileSerpent', src_code)
  end

  def new_filter(from_block: 'latest', to_block: 'latest', addr: nil, topics: nil)
    obj_par = {}
    obj_par[:fromBlock] = from_block if from_block
    obj_par[:toBlock] = to_block if to_block
    obj_par[:address] = addr if addr
    obj_par[:topics] = topics if topics

    send_post_request('eth_newFilter', obj_par)
  end

  def new_block_filter
    send_post_request('eth_newBlockFilter')
  end

  def new_pending_transaction_filter
    send_post_request('eth_newPendingTransactionFilter')
  end

  def uninstall_filter(filt_id)
    send_post_request('eth_uninstallFilter', filt_id)
  end

  def get_filter_changes(filt_id)
    send_post_request('eth_getFilterChanges', filt_id)
  end

  def get_filter_logs(filt_id)
    send_post_request('eth_getFilterLogs', filt_id)
  end

  def get_logs(filr_obj)
    send_post_request('eth_getLogs', filr_obj)
  end

  def get_work
    send_post_request('eth_getWork')
  end

  def submit_work(nonce:, pow:, mix_digest:)
    send_post_request('eth_submitWork', nonce, pow, mix_digest)
  end

  def submit_hashrate(hr, client_id)
    send_post_request('eth_submitHashrate', hr, client_id)
  end

  def web3_client_version
    send_post_request('web3_clientVersion')
  end

  def web3_sha3(data)
    send_post_request('web3_sha', data)
  end

  def net_version
    send_post_request('net_version')
  end

  def net_listening
    send_post_request('net_listening')
  end

  def net_peer_count
    send_post_request('net_peerCount')
  end

  def db_put_string(db, key, data)
    send_post_request('db_putString', db, key, data)
  end

  def db_get_string(db, key)
    send_post_request('db_getString', db, key)
  end

  def db_put_hex(db, key, data)
    send_post_request('db_putHex', db, key, data)
  end

  def db_get_hex(db, key)
    send_post_request('db_getHex', db, key)
  end

  def shh_version
    send_post_request('shh_version')
  end

  def shh_post(from: nil, to: nil, topics:, payload:, priority:, ttl:)
    obj_par = {topics: topics, payload: payload, priority: priority, ttl: ttl}
    obj_par[:from] = from if from
    obj_par[:to] = to if to
    send_post_request('shh_post', obj_par)
  end

  def shh_new_identity
    send_post_request('shh_newIdentity')
  end

  def shh_has_identity(addr)
    send_post_request('shh_hasIdentity', addr)
  end

  # todo
  # unclear what it's supposed to do
  # https://github.com/ethereum/wiki/wiki/JSON-RPC#shh_newgroup
  def shh_new_group(addr)
    send_post_request('shh_newGroup', addr)
  end

  # todo
  # unclear what it's supposed to do
  # https://github.com/ethereum/wiki/wiki/JSON-RPC#shh_addtogroup
  def shh_add_to_group(addr)
    send_post_request('shh_addToGroup', addr)
  end

  def shh_new_filter(to: nil, topics:)
    obj_par = {topics: topics}
    obj_par[:to] = to if to
    send_post_request('shh_newFilter', obj_par)
  end

  def shh_uninstall_filter(flt_id)
    send_post_request('shh_uninstallFilter', flt_id)
  end

  def shh_get_filter_changes(flt_id)
    send_post_request('shh_getFilterChanges', flt_id)
  end

  def shh_get_messages(flt_id)
    send_post_request('shh_getMessages', flt_id)
  end

  private

  BLOCK_TAGS = ['latest', 'earliest', 'pending']

  # todo move to mixin or parent class
  def send_post_request(name, *args)
    http = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.basic_auth @uri.user, @uri.password
    request.content_type = 'application/json'
    request.body = {method: name, params: args, id: 'jsonrpc'}.to_json
    resp = JSON.parse(http.request(request).body)
    raise CoinRPC::JSONRPCError, resp['error'] if resp['error']
    result = resp['result']
    result.is_a?(Hash) ? result.symbolize_keys : result
  rescue Errno::ECONNREFUSED
    raise CoinRPC::ConnectionRefusedError
  end

  def verify_block_number_or_tag!(block_num_or_tag)
    if block_num_or_tag.is_a?(String)
      if not BLOCK_TAGS.include?(block_num_or_tag.downcase)
        raise ArgumentError, "Tag must be a String of either value: 'latest', 'earliest' or 'pending'. Current value: #{block_num_or_tag}"
      end
    end
  end
end
