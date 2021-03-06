Feature: Start and stop Neo4j Server
  The Neo4j server should start and stop using a command line script

  Background:
    Given a platform supported by Neo4j
    And a working directory at relative path "target"
    And set Neo4j Home to "neo4j_home"
    And Neo4j Home should contain a Neo4j Server installation

  Scenario: Start Neo4j Server and query Spatial layers
    When I start Neo4j Server
    And wait for Server started at "http://localhost:7474/db/data/"
    Then "http://localhost:7474" should provide the Neo4j REST interface
    Then requesting "http://localhost:7474/db/data/ext/" should contain "SpatialPlugin"
    Then sending "layer=test&lon=lon&lat=lat" to "http://localhost:7474/db/data/ext/SpatialPlugin/graphdb/addSimplePointLayer" should contain "EditableLayerImpl"
    Then sending JSON "{"name":"test", "config":{"provider":"spatial"}}" to "http://localhost:7474/db/data/index/node/" should contain "node"
    Then updating "{"lon": 15.2, "lat": 60.1}" to "http://localhost:7474/db/data/node/0/properties" should have a response of "204"
    Then sending "layer=test&node=http://localhost:7474/db/data/node/0" to "http://localhost:7474/db/data/ext/SpatialPlugin/graphdb/addNodeToLayer" should contain "bbox"
    Then sending "layer=test&minx=15.0&maxx=15.3&miny=60.0&maxy=60.2" to "http://localhost:7474/db/data/ext/SpatialPlugin/graphdb/findGeometriesInBBox" should contain "node"
    Then sending JSON "{"query":"start n=node:test('bbox:[15.0, 16.0, 56.0, 61.0]') return n"}" to "http://localhost:7474/db/data/cypher" should contain "node"
    Then sending JSON "{"script":"g.idx('test').get('bbox','[15.0, 16.0, 56.0, 61.0]').toList()._().in()"}" to "http://localhost:7474/db/data/ext/GremlinPlugin/graphdb/execute_script" should contain "node"
    Then requesting "http://localhost:7474/db/data/index/node/test/bbox/%5B15.0%2C%2016.0%2C%2056.0%2C%2061.0%5D" should contain "node"
    