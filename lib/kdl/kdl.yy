class KDL::Parser
  options no_result_var
  token IDENT STRING RAWSTRING
        INTEGER FLOAT TRUE FALSE NULL
        WS NEWLINE
        LBRACE RBRACE
        LPAREN RPAREN
        EQUALS
        SEMICOLON
        EOF
        SLASHDASH
        ESCLINE
rule
  document  : nodes { KDL::Document.new(val[0]) }
            | linespaces { KDL::Document.new([])}

nodes           : none                      { [] }
                | linespaces node       { [val[1]] }
                | linespaces empty_node { [] }
                | nodes node                { [*val[0], val[1]] }
                | nodes empty_node          { val[0] }
  node          : untyped_node      { val[0] }
                | type untyped_node { val[1].as_type(val[0], @type_parsers.fetch(val[0], nil)) }
  untyped_node  : node_decl node_term                { val[0].tap { |x| x.children = [] } }
                | node_decl node_children node_term  { val[0].tap { |x| x.children = val[1] } }
                | node_decl empty_children node_term { val[0].tap { |x| x.children = [] } }
  node_decl     : identifier                              { KDL::Node.new(val[0]) }
                | node_decl ws value                      { val[0].tap { |x| x.arguments << val[2] } }
                | node_decl ws SLASHDASH ws_star value    { val[0] }
                | node_decl ws property                   { val[0].tap { |x| x.properties[val[2][0]] = val[2][1] } }
                | node_decl ws SLASHDASH ws_star property { val[0] }
  empty_node    : SLASHDASH ws_star node
  node_children : ws_star LBRACE nodes RBRACE { val[2] }
                | ws_star LBRACE linespaces RBRACE { [] }
  empty_children: SLASHDASH node_children
                | ws empty_children
  node_term: linespaces | semicolon_term
  semicolon_term: SEMICOLON | SEMICOLON linespaces

  type : LPAREN identifier RPAREN { val[1] }

  identifier: IDENT     { val[0].value }
            | STRING    { val[0].value }
            | RAWSTRING { val[0].value }

  property: identifier EQUALS value { [val[0], val[2]] }

  value : untyped_value
        | type untyped_value { val[1].as_type(val[0], @type_parsers.fetch(val[0], nil)) }

  untyped_value : IDENT      { KDL::Value::String.new(val[0].value) }
                | STRING     { KDL::Value::String.new(val[0].value) }
                | RAWSTRING  { KDL::Value::String.new(val[0].value) }
                | INTEGER    { KDL::Value::Int.new(val[0].value) }
                | FLOAT      { KDL::Value::Float.new(val[0].value, format: val[0].meta[:format]) }
                | boolean    { KDL::Value::Boolean.new(val[0]) }
                | NULL       { KDL::Value::Null }

  boolean : TRUE  { true }
          | FALSE { false }

  ws: WS | ESCLINE | WS ESCLINE | ESCLINE WS | WS ESCLINE WS
  ws_star: none | ws
  linespace: WS | NEWLINE | EOF
  linespaces: linespace | linespaces linespace

  none: { nil }

---- inner

  def parse(str, options = {})
    if options.fetch(:parse_types, true)
      @type_parsers = ::KDL::Types::MAPPING.merge(options.fetch(:type_parsers, {}))
    else
      @type_parsers = {}
    end
    @tokenizer = ::KDL::Tokenizer.new(str)
    do_parse
  end

  private

  def next_token
    @tokenizer.next_token
  end
