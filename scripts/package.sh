#!/bin/bash
echo "🔹 Empaquetando Lambda..."
rm -rf dist
mkdir dist
zip -r dist/payment-flow.zip src package.json node_modules > /dev/null
echo "✅ Empaquetado listo: dist/payment-flow.zip"
