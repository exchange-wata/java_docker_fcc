#!/bin/bash

# Gradleの継続ビルドでホットリロードを実現
echo "Starting Gradle continuous build..."
echo "File changes will trigger automatic recompilation and execution."
echo "Press Ctrl+C to stop."
echo "================================"

gradle run --continuous
