# AIGraph4pg : Frequently Asked Questions (FAQ)

This page addresses some of the **Frequently Asked Questions**
about the AIGraph4pg solution.  It will be updated in an ongoing
manner to address common customer questions.

## List of Questions

- [What is Azure PostgreSQL Flex Server?](#azure_postgresql)
- [What is Apache AGE?](#apache_age)
- [This repo uses Python, is Python required?](#is_python_required)

---

## Answers

<a name="azure_postgresql"></a>

**Q: What is Azure PostgreSQL Flex Server?**

**A:** Azure Database for PostgreSQL - Flexible Server is a relational database service based on the open-source Postgres database engine. It's a fully managed database-as-a-service that can handle mission-critical workloads with predictable performance, security, high availability, and dynamic scalability.

- [Introduction](https://azure.microsoft.com/en-us/products/postgresql/)
- [Documentation](https://learn.microsoft.com/en-us/azure/postgresql/)

Throughout this GitHub repo, the product name may often be referred to as simply
**Azure PostgreSQL**.



---

<a name="apache_age"></a>

**Q: What is Apache AGE?**

**A:** Apache AGE is a PostgreSQL extension that provides graph database functionality.
The graph query language that AGE uses is openCypher.
The AGE extension is now supported in Azure PostgreSQL Flex Server, thus enabling 
GraphRAG, OmniRAG, and AI-powered applications.

- [AGE Home Page](https://age.apache.org)
- [Introducing support for Graph data in Azure Database for PostgreSQL](https://techcommunity.microsoft.com/blog/adforpostgresql/introducing-support-for-graph-data-in-azure-database-for-postgresql-preview/4275628)

---

<a name="is_python_required"></a>

**Q: This repo uses Python, is Python required?**

**A:** This reference implementation was developed with the **Python**
programming language, but Python **isn't** required for your implementation.

There are PostgreSQL driver libraries in multiple programming languages
such as **Java, C#, Node.js/TypeScript, Ruby, Go, R**, and others.
Your solution can be built with your choice of a programming language
that supports PostgreSQL.
