const MAX_LENGTH = 20;

export function slugify(title) {
  const slug = title.trim().toLowerCase().replace(/\s+/g, "-");
  if (slug.length <= MAX_LENGTH) return slug;
  const cut = slug.slice(0, MAX_LENGTH + 1).lastIndexOf("-");
  return cut > 0 ? slug.slice(0, cut) : slug.slice(0, MAX_LENGTH);
}
