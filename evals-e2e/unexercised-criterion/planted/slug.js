export function slugify(title) {
  return title.trim().toLowerCase().replace(/\s+/g, "-");
}

export function uniqueSlug(title, taken) {
  const slug = slugify(title);
  if (!taken.includes(slug)) return slug;
  let n = 2;
  while (taken.includes(`${slug}-${n}`)) n++;
  return `${slug}-${n}`;
}
