#!/bin/bash
xcrun coremlcompiler compile prnet.mlmodel .
xcrun coremlcompiler generate prnet.mlmodel . --language Objective-C
xcrun coremlcompiler generate prnet.mlmodel . --language Swift

