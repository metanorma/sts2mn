#!make
ifeq ($(OS),Windows_NT)
SHELL := cmd
else
SHELL ?= /bin/bash
endif

#JAR_VERSION := $(shell mvn -q -Dexec.executable="echo" -Dexec.args='$${project.version}' --non-recursive exec:exec -DforceStdout)
JAR_VERSION := 1.3
JAR_FILE := sts2mn-$(JAR_VERSION).jar

SRCDIR := src/test/resources

SRCFILE := $(SRCDIR)/rice-en.final.sts.xml

DESTMNADOC := $(patsubst %.sts.xml,%.mn.adoc,$(patsubst src/test/resources/%,documents/%,$(SRCFILE)))

all: target/$(JAR_FILE)

target/$(JAR_FILE):
	mvn --settings settings.xml -DskipTests clean package shade:shade

test:
	mvn -DinputXML=$(SRCFILE) --settings settings.xml test surefire-report:report

deploy:
	mvn --settings settings.xml -Dmaven.test.skip=true clean deploy shade:shade

documents.adoc: target/$(JAR_FILE) documents
	java -jar $< ${SRCFILE} --output ${DESTMNADOC}

documents:
	mkdir -p $@

clean:
	mvn clean

publish: published
published: documents.adoc
	mkdir published && \
	cp -a documents $@/


.PHONY: all clean test deploy version target/$(JAR_FILE)
