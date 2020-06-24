#!make
SHELL ?= /bin/bash

JAR_VERSION := $(shell mvn -q -Dexec.executable="echo" -Dexec.args='$${project.version}' --non-recursive exec:exec -DforceStdout)
#JAR_VERSION := 1.0
JAR_FILE := sts2mn-$(JAR_VERSION).jar

SRCDIR := src/test/resources

SRCFILE := $(SRCDIR)/rice-en.final.sts.xml

#DESTDIR := documents
#DESTMNXML := $(patsubst %.sts.xml,%.mn.xml,$(patsubst src/test/resources/%,documents/%,$(SRCFILE)))

all: target/$(JAR_FILE)

target/$(JAR_FILE):
	mvn --settings settings.xml -DskipTests clean package shade:shade

test:
	mvn -DinputXML=$(SRCFILE) --settings settings.xml test surefire-report:report

deploy:
	mvn --settings settings.xml -Dmaven.test.skip=true clean deploy shade:shade

clean:
	mvn clean


.PHONY: all clean test deploy version target/$(JAR_FILE)
