
## AIGraph4pg Tutorial : Relational Functionality

##### PostgreSQL Documentation

There is a vast amount of documentation available for PostgreSQL, including:

* [Official documentation in HTML format](https://www.postgresql.org/docs/current/).
* [Official documentation in PDF format](https://www.postgresql.org/docs/).
  The PDF file alone is over 3100 pages long
* [Azure Database for PostgreSQL - Flexible Server documentation](https://learn.microsoft.com/en-us/azure/postgresql/)

This tutorial can't possibly cover the entire breadth and depth of PostgreSQL,
and therefore just focuses on the following topics related to this reference application -
Table Inheritance, JSON data, and the JSONB datatype.

---

##### Table Inheritance

You may already be familiar with the concept of
**inheritance in object-oriented programming (OOP)**.
Object Oriented Programming allows you to define a superclass with common
attributes and logic, then extend or inherit from that superclass to
create subclasses which use that common logic. This enables code reuse
and higher quality application code.
For example, an in an automative application, you could define superclass "Vehicle",
and subclasses "Sedan", "SUV", and "Coupe" that inherit from "Vehicle".PostgreSQL offers similar functionality. You can define a table,
then use the **INHERITS** keyword to create a new
table based on the parent table. The subtable can optionally add
additional columns, as shown below.
```

  CREATE TABLE cities (
      name            text,
      population      float,
      elevation       int
  );
  
  CREATE TABLE capitals (
      state           char(2)
  ) INHERITS (cities);
  
```
This feature is documented
[here](https://www.postgresql.org/docs/current/ddl-inherit.html) in the official PostgreSQL documentation.In the next section on Graph Queries you'll see that **Apache AGE**
makes extensive use of table inheritance.

---

##### JSON data and the JSONB datatype

PostgreSQL is one of the few relational databases that currently supports JSON data.
This functionality is becoming increasingly important as JSON has become the standard
data format for web services and APIs, and the trend in IT is toward more and more
unstructured data vs structure data.Please see the
[official documentation on JSON Types](https://www.postgresql.org/docs/current/datatype-json.html) here.This reference application contains one relational table named **legal\_cases**
and is created with the following DDL (Data Definition Language):
```

    DROP TABLE IF EXISTS legal_cases CASCADE;

    CREATE TABLE legal_cases (
        id                   bigserial primary key,
        name                 VARCHAR(1024),
        name_abbreviation    VARCHAR(1024),
        case_url             VARCHAR(1024),
        decision_date        DATE,
        court_name           VARCHAR(1024),
        citation_count       INTEGER,
        text_data            TEXT,
        json_data            JSONB,
        embedding            vector(1536)
    );
  
```
Note the column named **json\_data** with the **JSONB** datatype
which is populated with text data in the
[JSON](https://en.wikipedia.org/wiki/JSON) format.
JSONB is a binary representation of JSON data, and it supports indexing.To make the JSON data efficiently queryable, one should create an **index**
on the column. For JSONB columns, the
[GIN (Generalized Inverted Index)](https://www.postgresql.org/docs/current/gin.html) index type is recommended.
```

    DROP INDEX IF EXISTS idx_legal_cases_json_data_gin;

    CREATE INDEX idx_legal_cases_json_data_gin
    ON legal_cases USING gin (json_data);
  
```
This reference application populates this column with JSON values
that look like the following when "pretty printed" (see bottom of this page).
As you can see, it a large and deeply nested JSON object.This JSON data can now be queried, at any depth, with extensions to the SQL language.
For example, to query where the **decision\_date** attribute
for the value "1967-04-13", you could use the following SQL:
```

    select id, json_data
    from  legal_cases
    where json_data @> '{"decision_date": "1967-04-13"}'
    limit 5;
  
```
The JSON query syntax is further described here in the
[JSON Functions and Operators](https://www.postgresql.org/docs/current/functions-json.html) section of the official documentation.This query returns the following value, given the reference dataset.In the returned result set of one document, notice how there are many
**"cites\_to"** objects, but each of these do NOT have
the same structure. This is a good example of using the JSONB datatype
for schemaless and variable data in PostgreSQL.
```

    {
      "id": 1095193,
      "name": "Carrie Thomas, Respondent, v. Housing Authority of the City of Bremerton, Appellant",
      "court": {
        "id": 9029,
        "name": "Washington Supreme Court",
        "name_abbreviation": "Wash."
      },
      "analysis": {
        "sha256": "ef64570210a5daef08674658da854019fca9a103a1b1175ad61899b0f2783de7",
        "simhash": "1:f1d3bc51437a8e06",
        "pagerank": {
          "raw": 2.1057695284947042e-07,
          "percentile": 0.7624712869360337
        },
        "char_count": 24251,
        "word_count": 3992,
        "cardinality": 1216,
        "ocr_confidence": 0.634
      },
      "case_url": "https://static.case.law/wash-2d/71/cases/0069-01.json",
      "casebody": {
        "judges": [],
        "parties": [
          "Carrie Thomas, Respondent, v. Housing Authority of the City of Bremerton, Appellant."
        ],
        "opinions": [
          {
            "text": "Finley, C. J.\nOne morning, Carrie Thomas, then age 18 months u00e2u0080u0094 now the minor plaintiff in this lawsuit u00e2u0080u0094 was playing in the low-rent, 1-bedroom apartment which her parents leased from the defendant public housing authority. Her mother was not feeling well and was taking a nap in the bedroom. Carrieu00e2u0080u0099s 17-year-old uncle, Floyd Grubs, was engaged in washing and rinsing dishes in a mixture of hot and cold water. Suddenly Carrie screamed. Her young uncle rushed into the bathroom. He found the child standing beside a small pool of water which had overflowed from the washbasin. Her nightgown was soaking wet on the left side. Water so hot it approached boiling temperature filled the basin. The hot-water faucet handle was too hot to touch. Apparently Carrie had climbed up, turned on the faucet, and fallen into the washbasin after it had filled with water. The entire left side of her body was severely scalded. Second and third degree burns and permanent injuries resulted.\nCarrie Thomas and her parents had moved into their low-rent apartment unit some 4 months before the accident. It was one of 582 living units in the project known as West Park, operated by the defendant public housing authority. The Thomasesu00e2u0080u0099 written lease with defendant contained, inter alia, the following provisions:\nLiability u00e2u0080u0094 The Management shall not be responsible for loss or damage to property, nor injury to persons, occuring [sic] in or about the demised premises, by reason of any existing or future condition, defect, matter or thing in said demised premises or the property of which the premises are a part, nor for the acts, omissions or negligence of other persons or Tenants in and about the said property. The Tenant agrees to indemnify and save the Management, its representatives and employees harmless from all claims and liability for damage to property or injuries to persons occuring [sic] in or about the demised premises\nTenantu00e2u0080u0099s Responsibilities\nb. Entry u00e2u0080u0094 The Management may enter the premises during all reasonable time for inspection or repairs, or to remove signs, alterations or additions placed on the premises without permission.\nc. Damage u00e2u0080u0094 The tenant shall notify the Management immediately of necessary repairs or of damage to buildings or fixtures.\nThe heating appliance which furnished hot water for the Thomasesu00e2u0080u0099 apartment was about 22 years old at the time of the accident. A small plate or cover on the side of the water heater bore a legend reading u00e2u0080u009cremove plate for adjustment.u00e2u0080u009d Underneath the cover was a set screw which in effect operated as a lever to adjust the thermostat and the temperature of the water from extreme u00e2u0080u009chotu00e2u0080u009d to extreme u00e2u0080u009ccoldu00e2u0080u009d or some intermediate point. At the time plaintiff suffered her injuries, the mechanism was set all the way to the u00e2u0080u009chotu00e2u0080u009d position. Even if the mechanism had been set at a lower or colder temperature reading, nevertheless, the water temperature actually produced could have been extremely hot. This is because the set screw could be unscrewed, moved, and reset to vary and to make the entire temperature range either higher or lower. Testimony introduced at the trial was capable of supporting a jury finding that no one checked the position of the set screw or the temperature range of the water before Carrie and her parents moved into the apartment, nor while they resided there. Three times during the period in which the Thomases resided in the apartment, defendantu00e2u0080u0099s maintenance man serviced the water heater at the Thomasesu00e2u0080u0099 request. The servicing consisted of cleaning out soot, adjusting the air on the burner, and, on one occasion, relighting the pilot light; but it did not entail checking or changing the thermostat adjustment.\nThe water heater in question was tested after the accident. On the hottest setting, it produced water ranging from 180 to 208 degrees fahrenheit. On six arbitrarily chosen lower settings, it produced lower ranges of temperature down to 122 to 126 degrees on the lowest setting, with the one exception that it once produced water of 200 degrees on the middle setting after the burner was left on overnight. Expert testimony produced at the trial tended to show that, based on the distortion of a plastic toothbrush which had been in the washbasin, the water which scalded Carrie was approximately 200 degrees fahrenheit, or hotter.\nThis lawsuit was instituted by her guardian ad litem alleging that her injuries were proximately caused by the negligence of the defendant-appellant public housing authority. The jury returned a verdict for the plaintiff upon which judgment was entered, and the defendant appeals contending it is entitled to a judgment of dismissal as a matter of law. Defendant-appellantu00e2u0080u0099s three assignments of error raise three questions which we will now discuss:\nFirst, the defendant housing authority maintains that it was under no duty to prevent the injuries posed in plaintiffu00e2u0080u0099s complaint; i.e., it is not chargeable with negligence because the occurrence of the accident was not reasonably foreseeable. Anderson v. Reeder, 42 Wn.2d 45, 253 P.2d 423 (1953), and Fritsche v. Seattle, 10 Wn.2d 357, 116 P.2d 562 (1941), stand for the unquestioned proposition that when an accident occurs which is not reasonably foreseeable and which, according to common experience, is not likely to happen, a defendant is not chargeable with negligence. However, for a defendant to be held liable for maintaining a dangerous condition, proof as to foreseeability of the particular manner or nature of the occurrence is not necessary. It is sufficient if the general type of danger is reasonably foreseeable. Fleming v. Seattle, 45 Wn.2d 477, 275 P.2d 904 (1954).\nThe defendantu00e2u0080u0099s maintenance superintendent admitted on the witness stand that water even as hot as 180 degrees fahrenheit was dangerously hot. The fact that he considered it dangerous clearly implies that he could foresee that people could be exposed to it long enough to cause injury. This seems particularly pertinent in view of the well known fact that many small children were living in the low-rent public housing project.\nAs indicated hereinbefore, there was substantial evidu00c3u00a9nce produced at the trial to support a jury determination that the water which scalded Carrie was 200 degrees fahrenheit, or hotter. There was also evidence that the defendantu00e2u0080u0099s maintenance employees knew that the hot water from this type of hot water tank could and did reach 200 degrees, and hotter, when the thermostat was out of adjustment or the lever was on the highest setting. It should reasonably have been known to the defendantu00e2u0080u0099s agents that exposure to water of that heat even momentarily could cause serious injuries. Tending to support a conclusion that the injuries suffered by the plaintiff were a foreseeable consequence of the overly hot water is our decision in Kidwell v. School Dist. No. 300, 53 Wn.2d 672, 335 P. 2d 805 (1959). Therein, this court held that an injury to a child which occurred in the moving of a precariously balanced, high upright piano in a school activities room was sufficiently foreseeable to sustain liability.\nWe find further support for concluding that the injuries were reasonably foreseeable in a case involving a somewhat analogous factual pattern. In Thompson v. Paseo Manor South, Inc., 331 S.W.2d 1 (Mo. App. 1959), a 22-month-old child fell from her bed and came into contact with uninsulated and unprotected heating pipes which caused injuries for which suit was brought against the landlord. In reversing a judgment for the defendant landlord, the court, 331 S.W.2d at 6-7, made the following observation in regard to foreseeability:\nIt may be conceded that this child falling from its bed and becoming entangled in the pipes and receiving the injuries complained of was an unusual occurrence. But the landlord knew that the child occupied the apartment, and no doubt knew of children occupying other similar apartments. It is not the unusual manner of receiving injuries that determines liability, but whether the defendant could have reasonably anticipated that a child would receive injuries from the pipes. In Hammontree v. Edison Bros. Stores, Inc., Mo. App., 270 S.W.2d 117, 126, it is said: u00e2u0080u009cRelating to those dangers to be reasonably anticipated u00e2u0080u0094 if there is some probability or likelihood, not a mere possibility, of harm sufficiently serious that ordinary men would take precautions to avoid it, then the failure to do so is negligence. While the likelihood of a future happening is the test of a duty to anticipate, this does not mean the chances in favor of the happening must exceed those against it. The test is not the balance of probabilities, but of the existence of some probability of sufficient moment to induce the reasonable mind to take the precautions which would avoid it.u00e2u0080u009d (Italics ours.)\nWe think that the evidentiary pattern of the instant case meets the test or standard for establishing liability, i.e., the overly hot water posed a danger to tenants and children of tenants of the housing project which was sufficiently foreseeable to support a determination of liability. See also Housinq Authority of Birmingham v. Morris, 244 Ala. 557, 14 So. 2d 527 (1943).\nNext, the defendant maintains that assuming the water was excessively hot, it is not liable under applicable landlord-tenant law. The defendant cites such cases as Flannery v. Nelson, 59 Wn.2d 120, 366 P.2d 329 (1961), and Mesher v. Osborne, 75 Wash. 439, 134 Pac. 1092 (1913), for the proposition that a landlord is not liable for an obvious or patent defect, and is only liable for an obscure or latent defect, if he has actual knowledge of it. Conceding this to be a fair statement of the law of Washington and of some other states, nevertheless in many other jurisdictions, actual knowledge of the landlord is not required as the basis of liability if he has knowledge of facts which would lead a reasonable man to suspect the defect actually exists.\nAssuming our landlord and tenant law to be as indicated above, we are convinced the evidence in this case shows an obscure or latent defect or dangerous condition existed. Dr. Botimer testified that, in his opinion, if the water had been 140 degrees fahrenheit instead of 200 degrees, Carrie would not have suffered severe second and third degree burns on the entire left side of her body nor lost three fingers as she did, i.e., her injuries, if any, would have been very minor. From the testimony of various witnesses, the jury could have found that there is no way for the average person to tell the difference between water of 140 degrees fahrenheit and water heated to 200 degrees fahrenheit without using a high range thermometer, which the average person does not have and would not think of using. The verdict indicates a jury determination that the hot water heater or its condition at the time constituted an obscure or latent dangerous condition. A sufficient basis was laid relating to the issue involved, and the question was properly submitted to the jury for its determination. Howard v. Washington Water Power Co., 75 Wash. 255, 134 Pac. 927 (1913).\nThere is some dispute about the extent or the character of the knowledge of the defect necessary to render the defendant liable under existing law. The plaintiff points out that the type of water heater involved was installed throughout the housing project, and emphasizes evidence showing that the maintenance men of the defendant knew that this type of water heater could produce dangerously hot water. It is further emphasized that tenants sometimes unwittingly altered the temperature range of the heaters and that the projectsu00e2u0080u0099 hot water faucets thus on occasion produced not only water too hot for safe domestic use but even live steam. Plaintiff then cites Carusi v. Schulmerick, 98 F.2d 605 (D.C. Cir. 1938), wherein the landlordu00e2u0080u0099s agents knew of a latent defect in a particular type of window installed throughout an apartment building. The court seems to have held such knowledge was sufficient to render the landlord liable when, because of its dangerous condition, one such window fell and injured the plaintiff.\nContrariwise, the defendant cites Daulton v. Williams, 81 Cal. App. 2d 70, 183 P.2d 325 (1947). We do not find that case to be apposite. The court in Daulton specifically stated that the defect involved was a patent one.\nIn any event, we do not find it necessary to decide whether the defendant possessed the requisite knowledge solely on the basis of its knowledge as to the dangerous condition inherent in this type of water heater.\nThere was testimony that Floyd Grubs, while living in the Thomasesu00e2u0080u0099 apartment, had complained to defendantu00e2u0080u0099s maintenance man that the water in the apartment was too hot. This was a month or two before the accident and at a time when the maintenance man was cleaning the water heater in question. Neither Grubs nor the Thomases had reason to know how hot too hot was, but the defendantu00e2u0080u0099s maintenance personnel had good reason to know that too hot could be dangerously hot. There was sufficient evidence presented for the jury to conclude that the defendant had actual knowledge of the defect or dangerous conditions. See Howard v. Washington Power Co., supra.\nBeing aware of the danger, the defendant at the very least could have taken the following simple and economically feasible precautions: (1) check the temperature of the water produced by each water heater in the course of the regular between-tenants inspection of the apartments, and (2) advise all tenants, particularly new ones on their entry, to be careful regarding the hot water in the apartments and especially not to change the screw setting on the thermostat since this could cause the water to be heated to a dangerously hot temperature. Defendant took none of these steps in regard to the Thomases or the water heater in their apartment. Having failed to discharge its responsibility, the defendant must bear the consequences.\nThe defendantu00e2u0080u0099s third argument is that the provision of the lease, quoted above, which relates to liability is effective to release it from liability for Carrieu00e2u0080u0099s injuries. In support of the validity of this exculpatory clause, the defendant cites this courtu00e2u0080u0099s decisions in Magerstaedt v. Eric Co., 64 Wn.2d 298, 391 P.2d 533 (1964); Griffiths v. Henry Broder ick, Inc., 27 Wn.2d 901, 182 P.2d 18, 175 A.L.R. 1 (1947); and Broderson v. Rainier Natu00e2u0080u0099l Park Co., 187 Wash. 399, 60 P.2d 234 (1936). In the Griffiths case, the court held that an agreement by which a private apartment house owner held the manager harmless from liability for injuries resulting from any cause, including its own negligence, was not contrary to public policy. Because of the difference in the character and relationship of the parties to the agreement in Griffiths, that case is not determinative of the issue here presented.\nNeither is the Broderson case apposite, since there the issue concerned the validity of a release of liability clause whereby the defendant, which rented winter sports equipment, protected itself against liability to those patrons who voluntarily chose to participate in dangerous winter sports. We note, however, that the opinion in Broderson, 187 Wash, at 404, contains the following language:\nConsidering the question whether the waiver was void as against public policy, it is a well-recognized rule that corporations engaged in the performance of public duties, as for instance, common carriers, and, generally, those engaged in the operation of public utilities, cannot by contract relieve themselves of liability for negligence in the performance of their duty to the public or the measure of care they owe their patrons under the law. Hartford Fire Ins. Co. v. Chicago M. & S.P.R. Co., 175 U.S. 91, 20 S. Ct. 33; Railroad Co. v. Lockwood, 84 U.S. 357.\nIn the Magerstaedt decision, there is language which supports the validity of a lease provision relieving the corporate lessor from liability to the lessee of a restaurant for certain causes, although the exculpatory clause was not the basis of the decision in that case. The landlord-tenant relationship in that case, however, was quite different than in the instant matter.\nThe Laws of 1939, ch. 23, now codified as RCW 35.82, created the defendant public housing authority and enabled it to build and operate the West Park project in which the Thomases lived. It is noteworthy that RCW 35.82.010 reads in part as follows:\nFinding and declaration of necessity. It is 'hereby declared: (1) that there exist in the state insanitary or unsafe dwelling accommodations and that persons of low income are forced to reside in such insanitary or unsafe accommodations; that within the state there is a shortage of safe or sanitary dwelling accommodations available at rents which persons of low income can afford and that such persons are forced to occupy overcrowded and congested dwelling accommodations; . . . (2) that these areas in the state cannot be cleared, nor can the shortage of safe and sanitary dwellings for persons of low income be relieved, through the operation of private enterprise, and that the construction of housing projects for persons of low income (as herein defined) would therefore not be competitive with private enterprise; (3) that the clearance, replanning and reconstruction of the areas in which insanitary or unsafe housing conditions exist and the providing of safe and sanitary dwelling accommodations for persons of low income are public uses and purposes for which public money may be spent and private property acquired and are governmental functions of state concern; ....\nThe definition of u00e2u0080u009chousing project,u00e2u0080u009d as found in RCW 35.82.020, contains the following language:\n(9) u00e2u0080u009cHousing projectu00e2u0080u009d shall mean any work or undertaking: . . . (b) to provide decent, safe and sanitary urban or rural dwellings, apartments or other living accommodations for persons of low income; ....\nFrom this expression of the legislature, the conclusion is inescapable that two of the primary objectives in creating public housing authorities such as the defendant are: (1) to provide safe and sanitary housing, and (2) to make such housing available to persons of low income who otherwise would be forced to reside in unsanitary and unsafe housing.\nPublic housing such as that provided by the defendant is only available to u00e2u0080u009cpersons of low income,u00e2u0080u009d in other words, those who the legislature has determined are unable to obtain safe and sanitary housing elsewhere. The situation presents a classic example of unequal bargaining power. Dean Prosser analyzes the problem and the applicable law as follows:\nIt is quite possible for the parties expressly to agree that the defendant is under no obligation of care for the benefit of the plaintiff, and shall not be liable for the consequences of conduct which would otherwise be negligence. There is no public policy which prevents the parties from contracting as they see fit. Thus one who accepts a gratuitous pass on a railway train, or enters into a lease or some other relation, may agree that there shall be no responsibility for negligence.\nThe courts have refused to uphold such agreements, however, where one party is at such obvious disadvantage in bargaining power that the effect of the contract is to put him at the mercy of the otheru00e2u0080u0099s negligence. Prosser, Torts u00c2u00a7 55, at 305-06 (2d ed. 1955). (Italics ours.)\nWe think that the instant matter, in which the Thomases had to sign the defendantu00e2u0080u0099s standard lease form in order to acquire housing at West Park, is an example of an obvious disadvantage in bargaining power which would have the effect, if the exculpatory provision were upheld, of putting the tenants at the mercy of the defendant housing authorityu00e2u0080u0099s negligence. This would be contrary to the public policy inherent in the basic legislation and authorization relative to low rent public housing.\nIn support of its position on the validity of the exculpatory provision in the lease, the defendant also cites Manius v. Housing Authority of Pittsburgh, 350 Pa. 512, 39 A.2d 614 (1944). The Manius case did uphold a release clause in a lease between a tenant and a public housing authority against a challenge that it was void as against public policy. The Pennsylvania court did not give much consideration to the argument, however, and dismissed it rather summarily in a brief paragraph.\nIn Housing Authority of Birmingham v. Morris, 244 Ala. 557, 14 So.2d 527 (1943), the Supreme Court of Alabama held that a disclaimer of liability by a housing authority is not effective to insulate it from liability to its tenants for its own negligence. Curiously enough, the Morris case also involved a plaintiff who was scalded by hot water, the injury being caused by the defendantu00e2u0080u0099s negligent maintenance of a hot water heater. On rehearing, the court unanimously adhered to its prior opinion and concluded that the housing authority could not be allowed to u00e2u0080u009ccreate and maintain a trap to inflict personal injury upon its tenants.u00e2u0080u009d 14 So.2d at 535. The careful and exhaustive analysis of the Alabama court was based in part on consideration of the statutes which authorized and created the housing authority. These statutes, which the court quoted at length and which are very similar to those of this state found in RCW 35.82, emphasized that the purpose of the housing projects was to provide safe and sanitary housing for persons of low income. We believe the Morris decision is better and more carefully reasoned than that in Manius.\nWe conclude that it is against the public policy of this state, as expressed by the legislature, to allow a public housing authority, created to provide safe and sanitary housing for persons of low income, to exempt itself by prearrangement or contract from liability to its tenants for its own negligence.\nThe judgment is affirmed.\nDonworth, Rosellini, and Hamilton, JJ., and Barnett, J. Pro Tern., concur.\nSee, e.g., Wagner v. Kepler, 411 Ill. 368, 104 N.E.2d 231 (1951); Harrill v. Sinclair Ref. Co., 225 N.C. 421, 35 S.E.2d 240 (1945); Murphy v. Barlow Realty Co., 214 Minn. 64, 7 N.W.2d 684 (1943); Hines v. Wilcox, 96 Tenn. 148, 33 S.W. 914 (1896); Cutter v. Hamlen, 147 Mass. 471, 18 N.E. 397 (1888); and other cases and authorities cited in 2 Harper & James, Torts u00c2u00a7 27.16, at 1509, nn. 16 and 17 (1956). Dean Prosser considers the requirement of actual knowledge to be the minority view. Prosser, Torts u00c2u00a7 80, at 467 (2d ed. 1955). In the view of the Restatement (Second), Torts u00c2u00a7 358 (1) (1965), liability attaches if u00e2u0080u009cthe lessor knows or has reason to know of the condition, and realizes or should realize the risk involved, and has reason to expect that the lessee will not discover the condition or realize the risk.u00e2u0080u009d (Italics ours.)\nIt is also clear that the legislature had no intention of shielding housing authorities such as the defendant from suit, RCW 35.82.070 provides in part:\n2 Powers of authority. An authority shall constitute a public body corporate and politic, exercising public and essential governmental functions, and having all the powers necessary or convenient to carry out and effectuate the purposes and provisions of this chapter, including the following powers in addition to others herein granted: (1) To sue and be sued; ....\nAnother case in. which an exculpatory clause in a lease with a public housing authority was before an appellate court is Harper v Vallejo Housing Authority, 104 Cal. App. 2d 621, 232 P.2d 262 (1951). In that case, the court affirmed a judgment for the minor plaintiff in spite of the release provision in the lease. The court was not called upon to determine the validity of the provision, however, as the suit was only for the childu00e2u0080u0099s injuries and the court determined the release to be ineffective to contract away the minor plaintiffu00e2u0080u0099s rights.",
            "type": "majority",
            "author": "Finley, C. J."
          }
        ],
        "attorneys": [
          "Hullin, Ehrlichman, Carroll & Roberts, Jack E. Hullin, and Helen Graham Greear, for appellant.",
          "Kahin, Horswill, Keller, Rohrback, Waldo & Moren, Harold Far dal, Greenwood, Shiers & Kruse, and Frank A. Shiers, for respondent."
        ],
        "corrections": "",
        "head_matter": "[No. 38561.\nDepartment Two.\nApril 13, 1967.]\nCarrie Thomas, Respondent, v. Housing Authority of the City of Bremerton, Appellant.\nHullin, Ehrlichman, Carroll & Roberts, Jack E. Hullin, and Helen Graham Greear, for appellant.\nKahin, Horswill, Keller, Rohrback, Waldo & Moren, Harold Far dal, Greenwood, Shiers & Kruse, and Frank A. Shiers, for respondent.\nReported in 426 P.2d 836."
      },
      "cites_to": [
        {
          "cite": "426 P.2d 836",
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": -1
        },
        {
          "cite": "232 P.2d 262",
          "year": 1951,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "104 Cal. App. 2d 621",
          "year": 1951,
          "case_ids": [
            2263883
          ],
          "category": "reporters:state",
          "reporter": "Cal. App. 2d",
          "case_paths": [
            "/cal-app-2d/104/0621-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "18 N.E. 397",
          "year": 1888,
          "category": "reporters:state_regional",
          "reporter": "N.E.",
          "opinion_index": 0
        },
        {
          "cite": "147 Mass. 471",
          "year": 1888,
          "case_ids": [
            782512
          ],
          "category": "reporters:state",
          "reporter": "Mass.",
          "case_paths": [
            "/mass/147/0471-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "33 S.W. 914",
          "year": 1896,
          "category": "reporters:state_regional",
          "reporter": "S.W.",
          "opinion_index": 0
        },
        {
          "cite": "96 Tenn. 148",
          "year": 1896,
          "case_ids": [
            8536490
          ],
          "category": "reporters:state",
          "reporter": "Tenn.",
          "case_paths": [
            "/tenn/96/0148-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "7 N.W.2d 684",
          "year": 1943,
          "category": "reporters:state_regional",
          "reporter": "N.W.2d",
          "opinion_index": 0
        },
        {
          "cite": "214 Minn. 64",
          "year": 1943,
          "case_ids": [
            219822
          ],
          "category": "reporters:state",
          "reporter": "Minn.",
          "case_paths": [
            "/minn/214/0064-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "35 S.E.2d 240",
          "year": 1945,
          "category": "reporters:state_regional",
          "reporter": "S.E.2d",
          "opinion_index": 0
        },
        {
          "cite": "225 N.C. 421",
          "year": 1945,
          "case_ids": [
            8610306
          ],
          "category": "reporters:state",
          "reporter": "N.C.",
          "case_paths": [
            "/nc/225/0421-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "104 N.E.2d 231",
          "year": 1951,
          "category": "reporters:state_regional",
          "reporter": "N.E.2d",
          "opinion_index": 0
        },
        {
          "cite": "411 Ill. 368",
          "year": 1951,
          "case_ids": [
            5312919
          ],
          "category": "reporters:state",
          "reporter": "Ill.",
          "case_paths": [
            "/ill/411/0368-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "39 A.2d 614",
          "year": 1944,
          "category": "reporters:state_regional",
          "reporter": "A.2d",
          "opinion_index": 0
        },
        {
          "cite": "350 Pa. 512",
          "year": 1944,
          "case_ids": [
            461209
          ],
          "category": "reporters:state",
          "reporter": "Pa.",
          "case_paths": [
            "/pa/350/0512-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "84 U.S. 357",
          "case_ids": [
            62446
          ],
          "category": "reporters:federal",
          "reporter": "U.S.",
          "case_paths": [
            "/us/84/0357-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "175 U.S. 91",
          "weight": 2,
          "case_ids": [
            1239473
          ],
          "category": "reporters:federal",
          "reporter": "U.S.",
          "case_paths": [
            "/us/175/0091-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "60 P.2d 234",
          "year": 1936,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "187 Wash. 399",
          "year": 1936,
          "case_ids": [
            477678
          ],
          "category": "reporters:state",
          "reporter": "Wash.",
          "case_paths": [
            "/wash/187/0399-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "175 A.L.R. 1",
          "year": 1947,
          "category": "reporters:specialty",
          "reporter": "A.L.R.",
          "opinion_index": 0
        },
        {
          "cite": "182 P.2d 18",
          "year": 1947,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "27 Wn.2d 901",
          "year": 1947,
          "case_ids": [
            2520563
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/27/0901-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "391 P.2d 533",
          "year": 1964,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "64 Wn.2d 298",
          "year": 1964,
          "case_ids": [
            1043159
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/64/0298-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "183 P.2d 325",
          "year": 1947,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "81 Cal. App. 2d 70",
          "year": 1947,
          "case_ids": [
            4437232
          ],
          "category": "reporters:state",
          "reporter": "Cal. App. 2d",
          "case_paths": [
            "/cal-app-2d/81/0070-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "98 F.2d 605",
          "year": 1938,
          "case_ids": [
            990235
          ],
          "category": "reporters:federal",
          "reporter": "F.2d",
          "case_paths": [
            "/f2d/98/0605-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "134 Pac. 927",
          "year": 1913,
          "category": "reporters:state_regional",
          "reporter": "P.",
          "opinion_index": 0
        },
        {
          "cite": "75 Wash. 255",
          "year": 1913,
          "case_ids": [
            622625
          ],
          "category": "reporters:state",
          "reporter": "Wash.",
          "case_paths": [
            "/wash/75/0255-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "134 Pac. 1092",
          "year": 1913,
          "category": "reporters:state_regional",
          "reporter": "P.",
          "opinion_index": 0
        },
        {
          "cite": "75 Wash. 439",
          "year": 1913,
          "case_ids": [
            622661
          ],
          "category": "reporters:state",
          "reporter": "Wash.",
          "case_paths": [
            "/wash/75/0439-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "366 P.2d 329",
          "year": 1961,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "59 Wn.2d 120",
          "year": 1961,
          "case_ids": [
            1028362
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/59/0120-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "244 Ala. 557",
          "year": 1943,
          "weight": 5,
          "case_ids": [
            3668814
          ],
          "category": "reporters:state",
          "reporter": "Ala.",
          "pin_cites": [
            {
              "page": "535"
            }
          ],
          "case_paths": [
            "/ala/244/0557-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "270 S.W.2d 117",
          "case_ids": [
            10186343
          ],
          "category": "reporters:state_regional",
          "reporter": "S.W.2d",
          "pin_cites": [
            {
              "page": "126"
            }
          ],
          "case_paths": [
            "/sw2d/270/0117-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "331 S.W.2d 1",
          "year": 1959,
          "weight": 2,
          "case_ids": [
            10152471
          ],
          "category": "reporters:state_regional",
          "reporter": "S.W.2d",
          "pin_cites": [
            {
              "page": "6-7"
            }
          ],
          "case_paths": [
            "/sw2d/331/0001-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "335 P. 2d 805",
          "year": 1959,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "53 Wn.2d 672",
          "year": 1959,
          "case_ids": [
            1011254
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/53/0672-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "275 P.2d 904",
          "year": 1954,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "45 Wn.2d 477",
          "year": 1954,
          "case_ids": [
            2428179
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/45/0477-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "116 P.2d 562",
          "year": 1941,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "10 Wn.2d 357",
          "year": 1941,
          "case_ids": [
            2604371
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/10/0357-01"
          ],
          "opinion_index": 0
        },
        {
          "cite": "253 P.2d 423",
          "year": 1953,
          "category": "reporters:state_regional",
          "reporter": "P.2d",
          "opinion_index": 0
        },
        {
          "cite": "42 Wn.2d 45",
          "year": 1953,
          "case_ids": [
            5001076
          ],
          "category": "reporters:state",
          "reporter": "Wash. 2d",
          "case_paths": [
            "/wash-2d/42/0045-01"
          ],
          "opinion_index": 0
        }
      ],
      "citations": [
        {
          "cite": "71 Wash. 2d 69",
          "type": "official"
        }
      ],
      "file_name": "0069-01",
      "last_page": "80",
      "first_page": "69",
      "provenance": {
        "batch": "2018",
        "source": "Harvard",
        "date_added": "2019-08-29"
      },
      "jurisdiction": {
        "id": 38,
        "name": "Wash.",
        "name_long": "Washington"
      },
      "last_updated": "2024-02-27T16:16:18.331048+00:00",
      "decision_date": "1967-04-13",
      "docket_number": "No. 38561",
      "citation_count": 5,
      "last_page_order": 240,
      "first_page_order": 229,
      "name_abbreviation": "Thomas v. Housing Authority"
    }
  
```
