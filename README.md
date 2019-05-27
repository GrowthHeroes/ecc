# Easy Clean Code (ECC)

## TLDR;  CLI setup

* Fork this
* run `npm install`
* run `prettier --write "sfdx-source/ecc/main/default/**/*.{trigger,cls}"`
* download a PMD release build and copy it into /build/pmd
* run `sh build/pmd/bin/run.sh pmd -d sfdx-source/ecc/main/default -R apex-ruleset.xml  -f csv >> static-code-analysis.csv`

## Use Code Templates

* copy-paste a standard logicless Trigger
* copy-paste a standard TriggerHandler

## Use a Code Framework

* Common methods
* Utils class
* TestDataFactory with standard Objects
* git submodule include in client projects

## Standardize Formatting

GOAL: Consistent formatting in IDE, pre-commit and during Continuous Integration / Pull Request

* Prettier Apex
  * Usage:
    * `npm install --global prettier prettier-plugin-apex`
    * `prettier --write "sfdx-source/ecc/main/default/**/*.{trigger,cls}"`
  * Ignoring
    * Files: `.prettierignore`
  
* Call Prettier from VS Code or Illuminated Cloud
* Setup pre-commit run of Prettier
  * https://prettier.io/docs/en/precommit.html
  * https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
  * `ln -s dev-tools/pre-commit.sh .git/hooks/pre-commit`
* setup CLI run of Prettier and add to CI
* Etc.

## Code Review with PMD

GOAL: Catch bad code design early and also clean as you go

In VS Code
* https://marketplace.visualstudio.com/items?itemName=chuckjonas.apex-pmd
* add to settings.json: `"apexPMD.rulesets": ["apex-ruleset.xml"]` 

CLI
* Download from https://github.com/pmd/pmd/releases
* place in /build/pmd
* `sh build/pmd/bin/run.sh pmd -d sfdx-source/ecc/main/default -R apex-ruleset.xml  -f csv >> build/pmd-output.csv`
* Bonus: host your own stripped down copy and include it as a submodule, PMD is big

CI
* in `.gitlab-ci.yml`
  * creates a csv or xml artifact on gitlab you can download
* Bonus: Use Codacy to block PRs only when the Diff is worse / new issues were created


## Automate Apex Tests with Circle CI

https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ci_circle_config_env.htm
https://github.com/forcedotcom/sfdx-circleci

* add server.key.enc to /assets

## Automate PMD, ESLint, etc. with Codacy

* It will honor/use the apex-ruleset.xml file if you have one for PMD
* It will honor/usea ESLint and other config files as well

## Jest for LWC

https://github.com/salesforce/lwc-jest


## Thanks

There a ton of great people and resources out there that have helped me get this far. 