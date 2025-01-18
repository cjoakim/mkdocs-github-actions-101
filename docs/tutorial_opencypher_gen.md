
## AIGraph4pg Tutorial : Generative AI for openCypher

##### Generative AI

This reference application makes use of **Generative AI**
to generate openCypher and AGE SQL queries from natural language queries
provided by the user.This functionality enables the new class of
**GraphRAG** and **OmniRAG** applications.[RAG](https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-retrieval-augmented-generation-rag)
is the acronym for **Retrieval-augmented generation**. It is a pattern used
in Generative AI applications whereby you pass data to a **Large Language Model (LLM)**
to augment the knowledge base of the model so that it can generate more accurate output for you.Both the RAG data, and the user natural-language question, are passed to the LLM
in the form of a **prompt**. The prompt is typically text content,
and gives specific instructions to the LLM on how to generate the desired output.Generative AI applications are much more effective if they can pass the highest-quality
and most pertinent RAG data to the LLM. Initial RAG applications typically solely used
**vector search** to obtain their RAG data. While vector search is very effective
in some cases, it falls short in others. The **GraphRAG** pattern is used
to obtain the RAG data **either** from a vector search or from a graph database
query. Graph databases, such as **Apache AGE in Azure Postgresql** can be used to
implement **knowledge graphs** that can be very effective in providing RAG data.The **OmniRAG** pattern takes this concept one step further by allowing the
application to obtain RAG data from an arbitrary **n-number of data sources**.
Azure PostgreSQL is well-suited for both GraphRAG and OmniRAG applications.
For example, Azure PostgreSQL supports the
[postgres\_fdw](https://www.postgresql.org/docs/current/postgres-fdw.html)
extension to connect to other (i.e. - "foreign") PostgreSQL databases.

---

##### Generative AI Implementation in this Reference Application

To generate the openCypher and AGE SQL queries from the user natural language,
this reference application calles the **Azure OpenAI service**
in two steps. Step one is to generate an openCypher query from the user natural language.
Step two is to wrap the generated openCypher query in an AGE SQL query.
The LLM used here is a deployment of the Azure OpenAI **gpt-4o** model.
The LLM is invoked via the **openai python library**; see file
"python/src/services/ai\_service.py" in the repository source code for details.The prompt for the first LLM step looks like this:
```

You are a helpful agent designed to generate an openCypher graph query
given a graph schema and a user natural language question.

## Graph Schema:

The following describes the schema of the legal_cases graph database:

The graph has one node type: Case.

A sample Case node with its attributes and datatypes is shown as JSON below.

{
    "id": 844424930133136,
    "label": "Case",
    "properties": {
        "id": 594079,
        "url": "https://static.case.law/wash/79/cases/0643-01.json",
        "name": "Martindale Clothing Co. v. Spokane & Eastern Trust Co.",
        "court": "Washington Supreme Court",
        "court_id": 9029,
        "decision_year": 1914,
        "citation_count": 5
    }
}

There are two possible Edges between Case Nodes; "cites" and "cited_by".

A sample "cites" Edge with its attributes and datatypes is shown as JSON below.

{
    "id": 1407374883553314,
    "label": "cites",
    "end_id": 844424930131969,
    "start_id": 844424930131976,
    "properties": {
      "case_id": "1005793",
      "case_name": "Traverso v. Pupo",
      "cited_case_id": "1002109",
      "cited_case_name": "Cline v. Department of Labor & Industries",
      "cited_case_year": 1957
    }
}

A sample "cited_by" Edge with its attributes and datatypes is shown as JSON below.

{
    "id": 1125899906842625,
    "label": "cited_by",
    "end_id": 844424930131976,
    "start_id": 844424930131969,
    "properties": {
        "case_id": "1002109",
        "case_name": "Cline v. Department of Labor & Industries",
        "cited_case_id": "1005793",
        "cited_case_name": "Traverso v. Pupo",
        "cited_case_year": 1957
    }
}

## Natural Language:

The user has asked the following natural language question:
<< natural_language >>

## Result Format:

Only return the text of the openCypher query.

Please generate the openCypher query for the given natural language question
and given the schema.

## Examples:

Example 1:
natural_language input:  Lookup Case id 594079
openCypher query output: MATCH (c:Case {id:594079}) RETURN c 

Example 2:
natural_language input:  Traverse the cites edges from Case id 594079 to a depth of two cases. Return the Edge pairs.
openCypher query output: MATCH (c1:Case {id:594079})-[r1:cites]->(c2:Case)-[r2:cites]->() RETURN r1, r2
  
```
The prompt for the second LLM step looks like this:
```

You are a helpful agent designed to generate Apache AGE SQL from 
a given graphName and openCypher query.

You should wrap the SQL around the openCypher query.

## Inputs:

graphName: << graph_name >>

openCypher: << open_cypher >>

## Result Format:

Only return the text of the Apache AGE SQL.

## Examples:

Example 1:
graphName:   legal_cases
openCypher:  MATCH (c:Case {id:594079}) RETURN c 
AGE SQL:     select * from ag_catalog.cypher('legal_cases', $$ MATCH (c:Case {id:594079}) RETURN c $$) as (c agtype);

Example 2:
graphName:   legal_cases
openCypher:  MATCH (c1:Case)-[r1:cites]->(c2:Case)-[r2:cites]->() RETURN r1, r2 limit 3 
AGE SQL:     select * from ag_catalog.cypher('legal_cases', $$ MATCH (c1:Case)-[r1:cites]->(c2:Case)-[r2:cites]->() RETURN r1, r2 limit 3 $$) as (r1 agtype, r2 agtype);

Example 3:
graphName:   legal_cases
openCypher:  MATCH (c1:Case)-[r1:cited_by]->(c2:Case)-[r2:cited_by]->() RETURN r1, r2
AGE SQL:     select * from ag_catalog.cypher('legal_cases', $$ MATCH (c1:Case)-[r1:cited_by]->(c2:Case)-[r2:cited_by]->() RETURN r1, r2 $$) as (r1 agtype, r2 agtype);
  
```
The above two prompts are python **Jinja2** templates that are provided
dynamic values (i.e. - natural\_language, graph\_name, and open\_cypher) at runtime for text generation.
These two prompts are files "python/templates/cypher\_gen\_llm\_prompt.txt" and
"python/templates/wrap\_opencypher\_in\_age\_sql.txt" in the repository source code.Please feel free to modify these prompts to suit your own application needs.
The of [Prompt Engineering](https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-retrieval-augmented-generation-rag) is fast evolving.
