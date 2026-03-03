import os
import re

TEST_DIR = "test"

# Mapping entity constructions to missing args. We will do a generic regex replace for each file
entities = {
    "UserEntity": [("createdAt:", "createdAt: DateTime.now()")],
    "ProfileEntity": [("createdAt:", "createdAt: DateTime.now()"), ("updatedAt:", "updatedAt: DateTime.now()")],
    "MusicianEntity": [("updatedAt:", "updatedAt: DateTime.now()")],
    "GigOfferEntity": [("updatedAt:", "updatedAt: DateTime.now()")],
    "BookingEntity": [("createdAt:", "createdAt: DateTime.now()")],
    "StudioEntity": [], # None required
    "JamSessionEntity": [("createdAt:", "createdAt: DateTime.now()")],
    "RehearsalEntity": [], # None required
}

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    # For every entity type
    for obj_name, missing_fields in entities.items():
        if obj_name not in content:
            continue
            
        # We find every instantiation: obj_name( ... )
        # Since dart supports nested parentheses we use logic to trace opening/closing parens
        res = []
        i = 0
        while i < len(content):
            match = content.find(obj_name + '(', i)
            if match == -1:
                res.append(content[i:])
                break
            
            # Found obj_name(
            start_idx = match + len(obj_name)
            res.append(content[i:start_idx])
            
            i = start_idx
            
            # Count parens
            paren_count = 0
            end_match = -1
            for j in range(start_idx, len(content)):
                if content[j] == '(':
                    paren_count += 1
                elif content[j] == ')':
                    paren_count -= 1
                    if paren_count == 0:
                        end_match = j
                        break
            
            if end_match != -1:
                # Extracted args string between start_idx+1 and end_match-1
                args_str = content[start_idx+1:end_match]
                
                # Check for missing fields
                to_append = []
                for field_key, field_val in missing_fields:
                    if field_key not in args_str:
                        to_append.append(field_val)
                
                if len(to_append) > 0:
                    # Append them:
                    if not args_str.strip().endswith(','):
                         args_str += ','
                    args_str += '\n      ' + ',\n      '.join(to_append) + ','
                
                res.append('(' + args_str + ')')
                i = end_match + 1
            else:
                res.append(content[i:])
                break

        content = "".join(res)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print("Fixed " + filepath)

for r, d, f in os.walk(TEST_DIR):
    for filename in f:
        if filename.endswith(".dart"):
            fix_file(os.path.join(r, filename))
