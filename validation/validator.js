'use strict';

const path = require('path');
const catalog = require(path.join(__dirname, '..', 'catalog', 'bricks-catalog.json'));

function createCatalogIndex(catalogData) {
  if (!catalogData || !Array.isArray(catalogData.elements)) {
    throw new Error('Invalid catalog format: expected an object with an elements array.');
  }

  return new Map(catalogData.elements.map((element) => [element.name, element]));
}

function formatNodePath(pathSegments) {
  return pathSegments.length ? pathSegments.join('.') : 'root';
}

function validateSettings(node, definition, nodePath) {
  if (node.settings === undefined) {
    return;
  }

  if (node.settings === null || typeof node.settings !== 'object' || Array.isArray(node.settings)) {
    throw new Error(`Invalid settings at "${nodePath}": settings must be an object.`);
  }

  const allowed = new Set(definition.allowedSettings || []);
  for (const key of Object.keys(node.settings)) {
    if (!allowed.has(key)) {
      throw new Error(
        `Invalid setting "${key}" at "${nodePath}" for element "${node.element}". Allowed settings: ${[...allowed].join(', ') || '(none)'}.`
      );
    }
  }
}

function validateChildren(node, definition, catalogIndex, nodePath, pathSegments) {
  const hasChildren = node.children !== undefined;

  if (!hasChildren) {
    return;
  }

  if (!definition.supportsChildren) {
    throw new Error(`Element "${node.element}" at "${nodePath}" does not support children.`);
  }

  if (!Array.isArray(node.children)) {
    throw new Error(`Invalid children at "${nodePath}": children must be an array.`);
  }

  const allowedChildren = definition.allowedChildren;
  for (let i = 0; i < node.children.length; i += 1) {
    const child = node.children[i];
    const childPathSegments = [...pathSegments, `children[${i}]`];
    const childPath = formatNodePath(childPathSegments);

    if (allowedChildren !== '*' && Array.isArray(allowedChildren) && !allowedChildren.includes(child.element)) {
      throw new Error(
        `Invalid child "${child.element}" at "${childPath}" for parent "${node.element}". Allowed children: ${allowedChildren.join(', ') || '(none)'}.`
      );
    }

    validateNode(child, catalogIndex, childPathSegments);
  }
}

function validateNode(node, catalogIndex, pathSegments = []) {
  const nodePath = formatNodePath(pathSegments);

  if (!node || typeof node !== 'object' || Array.isArray(node)) {
    throw new Error(`Invalid node at "${nodePath}": expected an object.`);
  }

  if (!node.element || typeof node.element !== 'string') {
    throw new Error(`Missing or invalid "element" at "${nodePath}".`);
  }

  const definition = catalogIndex.get(node.element);
  if (!definition) {
    throw new Error(`Unknown element "${node.element}" at "${nodePath}". Add it to bricks-catalog.json.`);
  }

  if (!definition.supportsChildren && node.children !== undefined && Array.isArray(node.children) && node.children.length > 0) {
    throw new Error(`Element "${node.element}" at "${nodePath}" cannot contain children.`);
  }

  validateSettings(node, definition, nodePath);
  validateChildren(node, definition, catalogIndex, nodePath, pathSegments);

  return true;
}

function validateLayoutTree(layoutTree, catalogData = catalog) {
  const catalogIndex = createCatalogIndex(catalogData);
  return validateNode(layoutTree, catalogIndex, []);
}

module.exports = {
  createCatalogIndex,
  validateNode,
  validateLayoutTree
};
