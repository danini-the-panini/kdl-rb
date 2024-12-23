class KDL::V1::Parser
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
rule
  document  : nodes { @output_module::Document.new(val[0]) }
            | linespaces { @output_module::Document.new([]) }

  nodes          : none                        { [] }
                 | linespaces node             { [val[1]] }
                 | linespaces empty_node       { [] }
                 | nodes node                  { [*val[0], val[1]] }
                 | nodes empty_node            { val[0] }
  node           : unterm_node node_term       { val[0] }
  unterm_node    : untyped_node      { val[0] }
                 | type untyped_node { val[1].as_type(val[0], @type_parsers.fetch(val[0], nil)) }
  untyped_node   : node_decl                                               { val[0].tap { |x| x.children = [] } }
                 | node_decl node_children                                 { val[0].tap { |x| x.children = val[1] } }
                 | node_decl empty_childrens                               { val[0].tap { |x| x.children = [] } }
                 | node_decl empty_childrens node_children                 { val[0].tap { |x| x.children = val[2] } }
                 | node_decl node_children empty_childrens                 { val[0].tap { |x| x.children = val[1] } }
                 | node_decl empty_childrens node_children empty_childrens { val[0].tap { |x| x.children = val[2] } }
  node_decl      : identifier                           { @output_module::Node.new(val[0]) }
                 | node_decl ws_plus value              { val[0].tap { |x| x.arguments << val[2] } }
                 | node_decl ws_plus slashdash value    { val[0] }
                 | node_decl ws_plus property           { val[0].tap { |x| x.properties[val[2][0]] = val[2][1] } }
                 | node_decl ws_plus slashdash property { val[0] }
                 | node_decl ws_plus                    { val[0] }
  empty_node     : slashdash node
  node_children  : ws_star LBRACE nodes RBRACE                          { val[2] }
                 | ws_star LBRACE linespaces RBRACE                     { [] }
                 | ws_star LBRACE nodes unterm_node ws_star RBRACE      { [*val[2], val[3]] }
                 | ws_star LBRACE linespaces unterm_node ws_star RBRACE { [val[3]] }
  empty_children : slashdash node_children
                 | ws_plus empty_children
  empty_childrens: empty_children | empty_childrens empty_children
  node_term: linespaces | semicolon_term
  semicolon_term: SEMICOLON | SEMICOLON linespaces
  slashdash: SLASHDASH | slashdash ws_plus | slashdash linespaces

  type : LPAREN ws_star identifier ws_star RPAREN { val[2] }

  identifier : IDENT     { val[0].value }
             | STRING    { val[0].value }
             | RAWSTRING { val[0].value }

  property : identifier EQUALS value { [val[0], val[2]] }

  value : untyped_value
        | type untyped_value { val[1].as_type(val[0], @type_parsers.fetch(val[0], nil)) }

  untyped_value : STRING     { @output_module::Value::String.new(val[0].value) }
                | RAWSTRING  { @output_module::Value::String.new(val[0].value) }
                | INTEGER    { @output_module::Value::Int.new(val[0].value) }
                | FLOAT      { @output_module::Value::Float.new(val[0].value, format: val[0].meta[:format]) }
                | boolean    { @output_module::Value::Boolean.new(val[0]) }
                | NULL       { @output_module::Value::Null }

  boolean : TRUE  { true }
          | FALSE { false }

  ws_plus: WS | WS ws_plus
  ws_star: none | ws_plus
  linespace: WS | NEWLINE | EOF
  linespaces: linespace | linespaces linespace

  none: { nil }

---- inner

  def parse(str, parse_types: true, type_parsers: {}, output_module: ::KDL::V1)
    @output_module = output_module
    if parse_types
      @type_parsers = ::KDL::Types::MAPPING.merge(type_parsers)
    else
      @type_parsers = {}
    end
    @tokenizer = ::KDL::V1::Tokenizer.new(str)
    do_parse
  end

  private

  def next_token
    @tokenizer.next_token
  end
