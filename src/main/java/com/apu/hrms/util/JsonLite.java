package com.apu.hrms.util;

/**
 * Tiny JSON serializer for embedding report maps and lists in JSP pages.
 */
public final class JsonLite {

    private JsonLite() {
    }

    public static String toJson(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof String string) {
            return "\"" + escape(string) + "\"";
        }
        if (value instanceof Number || value instanceof Boolean) {
            return String.valueOf(value);
        }
        if (value instanceof java.util.Map<?, ?> map) {
            StringBuilder result = new StringBuilder("{");
            boolean first = true;
            for (var entry : map.entrySet()) {
                if (!first) {
                    result.append(',');
                }
                first = false;
                result.append(toJson(String.valueOf(entry.getKey())));
                result.append(':');
                result.append(toJson(entry.getValue()));
            }
            result.append('}');
            return result.toString();
        }
        if (value instanceof Iterable<?> iterable) {
            StringBuilder result = new StringBuilder("[");
            boolean first = true;
            for (Object item : iterable) {
                if (!first) {
                    result.append(',');
                }
                first = false;
                result.append(toJson(item));
            }
            result.append(']');
            return result.toString();
        }
        return toJson(String.valueOf(value));
    }

    private static String escape(String value) {
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
