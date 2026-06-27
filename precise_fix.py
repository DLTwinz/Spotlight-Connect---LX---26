with open('lib/nav.dart', 'r') as f:
    lines = f.readlines()

# Find the exact boundaries of the target function
start_idx = None
end_idx = None

for i, line in enumerate(lines):
    if "String defaultDashboardRouteFor(UserModel u)" in line:
        start_idx = i
    if start_idx is not None and "return AppRoutes.audience;" in line:
        # Check if the next non-empty line contains a closing brace
        for j in range(i + 1, len(lines)):
            if lines[j].strip():
                if lines[j].strip() == "}":
                    end_idx = j
                break
        if end_idx is not None:
            break

if start_idx is not None and end_idx is not None:
    replacement = [
        "        String defaultDashboardRouteFor(UserModel u) {\n",
        "          if (u.approvedRoles.contains('admin')) {\n",
        "            if (u.activeRole == 'talent') return AppRoutes.talent;\n",
        "            if (u.activeRole == 'business') return AppRoutes.business;\n",
        "            if (u.activeRole == 'audience') return AppRoutes.audience;\n",
        "            return AppRoutes.admin;\n",
        "          }\n",
        "          if (u.activeRole == 'talent' && u.approvedRoles.contains('talent')) {\n",
        "            return AppRoutes.talent;\n",
        "          }\n",
        "          if (u.activeRole == 'business' && u.approvedRoles.contains('business')) {\n",
        "            return AppRoutes.business;\n",
        "          }\n",
        "          return AppRoutes.audience;\n",
        "        }\n"
    ]
    
    # Splice the new implementation exactly into place
    lines[start_idx:end_idx + 1] = replacement
    
    with open('lib/nav.dart', 'w') as f:
        f.writelines(lines)
    print("Successfully patched defaultDashboardRouteFor cleanly!")
else:
    print("Error: Could not locate the target lines cleanly.")
